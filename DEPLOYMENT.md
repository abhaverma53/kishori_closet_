# Kishori Closet deployment

The recommended way to run this store in production is **Docker**. The Dockerfile builds the Rails app; `docker-compose.yml` runs it with PostgreSQL.

You still need a domain and a VPS. You do **not** need to install Ruby, Node, or PostgreSQL on the host.

## What to purchase and prepare

1. **Domain name** such as `kishoricloset.com`.
2. **Ubuntu VPS** (2 GB RAM minimum, 4 GB preferred) from DigitalOcean, Hetzner, AWS Lightsail, or similar.
3. **DNS records** pointing at the VPS:

   | Type | Name | Value |
   | --- | --- | --- |
   | A | `@` | your VPS public IP |
   | A | `www` | your VPS public IP |

4. **Gmail App Password** if you want order emails (`SMTP_USERNAME` / `SMTP_PASSWORD`).

---

## Docker (recommended)

### 1. Install Docker on the VPS

```bash
sudo apt update
sudo apt install -y git curl ca-certificates
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
```

Log out and back in so the `docker` group applies. Check:

```bash
docker --version
docker compose version || docker-compose --version
```

Use `docker compose` if that works, otherwise `docker-compose` (older Ubuntu). The commands below use `docker compose`; swap the name if needed.

### 2. Clone the app

```bash
sudo mkdir -p /var/www/kishori_closet
sudo chown $USER:$USER /var/www/kishori_closet
git clone https://github.com/abhaverma53/kishori_closet_.git /var/www/kishori_closet
cd /var/www/kishori_closet
```

### 3. Create `.env`

```bash
cp .env.example .env
openssl rand -hex 64
```

Paste the generated value into `.env` as `SECRET_KEY_BASE`. Then edit the rest:

```bash
SECRET_KEY_BASE=the-long-hex-value
APP_HOST=kishoricloset.com
FORCE_SSL=true
POSTGRES_PASSWORD=choose-a-strong-database-password
SMTP_USERNAME=kishoricloset@gmail.com
SMTP_PASSWORD=your-gmail-app-password
```

`FORCE_SSL=true` is correct when Nginx (or Caddy) terminates HTTPS in front of Docker. For a first local test on the VPS at `http://SERVER_IP:3000`, use `APP_HOST=localhost` and `FORCE_SSL=false`.

Never commit `.env`.

### 4. Build and start

```bash
cd /var/www/kishori_closet
docker compose up -d --build
docker compose logs -f web
```

Wait until logs show Puma listening. Then:

- Local / IP test: http://YOUR_SERVER_IP:3000
- Health check: http://YOUR_SERVER_IP:3000/up

The first start runs `db:migrate`. It does **not** load sample products. Create an admin (or load demo data) once:

```bash
# Demo catalog and logins (wipes orders/products — only on a fresh empty store)
docker compose exec web bin/rails db:seed
```

Demo admin: `admin@kishoricloset.com` / `password123`. Change that password immediately.

To create an admin without seeding:

```bash
docker compose exec web bin/rails runner 'User.create!(name: "Kishori Admin", email: "admin@kishoricloset.com", password: "choose-a-strong-password", password_confirmation: "choose-a-strong-password", phone: "8722403536", role: :admin)'
```

### 5. HTTPS with Nginx on the VPS

Keep Docker listening on localhost only. In `.env` set `PORT=3000`, then in `docker-compose.yml` change the ports line to `"127.0.0.1:3000:3000"` after the first successful test, recreate the web service, and install Nginx:

```bash
sudo apt install -y nginx certbot python3-certbot-nginx
```

Create `/etc/nginx/sites-available/kishori_closet`:

```nginx
server {
  listen 80;
  server_name kishoricloset.com www.kishoricloset.com;

  location / {
    proxy_pass http://127.0.0.1:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    client_max_body_size 20M;
  }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/kishori_closet /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
sudo certbot --nginx -d kishoricloset.com -d www.kishoricloset.com --email kishoricloset@gmail.com --agree-tos --redirect
```

Set in `.env`:

```bash
APP_HOST=kishoricloset.com
FORCE_SSL=true
```

```bash
docker compose up -d
```

### 6. Firewall

```bash
sudo ufw allow OpenSSH
sudo ufw allow "Nginx Full"
sudo ufw enable
```

Do not expose PostgreSQL to the internet. Docker's `db` service is only on the internal compose network.

### 7. After each code update

```bash
cd /var/www/kishori_closet
git pull
docker compose up -d --build
```

That rebuilds the image, runs new migrations on boot, and restarts the app. Product images live in the `storage_data` volume and survive rebuilds. Back that volume up.

Useful commands:

```bash
docker compose ps
docker compose logs -f web
docker compose exec web bin/rails console
docker compose down          # stop (keeps database + images)
```

### Run Docker on your laptop first

```bash
cp .env.example .env
# set SECRET_KEY_BASE (openssl rand -hex 64)
# APP_HOST=localhost
# FORCE_SSL=false
# POSTGRES_PASSWORD=anything-local
docker compose up --build
```

Open http://localhost:3000

---

## Native Ubuntu install (no Docker)

Use this only if you do not want containers. This guide is for an Ubuntu VPS with Nginx, Puma, Rails and PostgreSQL.

### 1. Server packages

SSH into the VPS:

```bash
sudo apt update
sudo apt install -y git curl build-essential libpq-dev postgresql postgresql-contrib nginx certbot python3-certbot-nginx libyaml-dev
```

Install Ruby 3.2.0 with rbenv:

```bash
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
rbenv install 3.2.0
rbenv global 3.2.0
gem install bundler:2.5.7
```

Node is only needed if you later change the JS pipeline. This app uses importmap + the Tailwind gem, so Node is not required on the server.

### 2. PostgreSQL

```bash
sudo -u postgres createuser -s kishori_closet
sudo -u postgres psql -c "ALTER USER kishori_closet WITH PASSWORD 'choose-a-strong-password';"
sudo -u postgres createdb -O kishori_closet kishori_closet_production
```

### 3. App user and code

```bash
sudo adduser --disabled-password --gecos "" deploy
sudo mkdir -p /var/www/kishori_closet
sudo chown deploy:deploy /var/www/kishori_closet
```

As `deploy`, clone the repository:

```bash
cd /var/www/kishori_closet
git clone YOUR_GIT_URL .
bundle config set --local without 'development test'
bundle install
```

Copy `config/master.key` from your local machine to the server, or set `RAILS_MASTER_KEY` in the systemd unit below. Never commit the master key.

### 4. Rails production environment

Create `/var/www/kishori_closet/.env` or export these in the systemd service:

```bash
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
APP_HOST=kishoricloset.com
FORCE_SSL=true
SHIPPING_FEE=0
DATABASE_URL=postgres://kishori_closet:choose-a-strong-password@localhost/kishori_closet_production
SECRET_KEY_BASE=run-bin-rails-secret-and-paste
```

Then:

```bash
cd /var/www/kishori_closet
RAILS_ENV=production bundle exec rails db:migrate
RAILS_ENV=production bundle exec rails db:seed   # optional sample data; skip on a live store
RAILS_ENV=production bundle exec rails assets:precompile
RAILS_ENV=production bundle exec rails tmp:create
```

Active Storage files are stored in `storage/`. Back this folder up; it contains product images.

### 5. Puma systemd service

Create `/etc/systemd/system/kishori_closet.service`:

```ini
[Unit]
Description=Kishori Closet Puma
After=network.target postgresql.service

[Service]
Type=simple
User=deploy
WorkingDirectory=/var/www/kishori_closet
Environment=RAILS_ENV=production
Environment=APP_HOST=kishoricloset.com
Environment=FORCE_SSL=true
Environment=SHIPPING_FEE=0
Environment=DATABASE_URL=postgres://kishori_closet:PASSWORD@localhost/kishori_closet_production
Environment=SECRET_KEY_BASE=YOUR_SECRET
Environment=RAILS_SERVE_STATIC_FILES=true
Environment=RAILS_LOG_TO_STDOUT=true
Environment=SMTP_USERNAME=kishoricloset@gmail.com
Environment=SMTP_PASSWORD=your-gmail-app-password
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now kishori_closet
sudo systemctl status kishori_closet
```

### 6. Nginx and HTTPS

Same Nginx + Certbot steps as in the Docker section above, proxying to `127.0.0.1:3000`.

### 7. After each update (native)

```bash
cd /var/www/kishori_closet
git pull
bundle install
RAILS_ENV=production bundle exec rails db:migrate
RAILS_ENV=production bundle exec rails assets:precompile
sudo systemctl restart kishori_closet
```
