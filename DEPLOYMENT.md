# Kishori Closet deployment

Do not deploy until the app is running locally. This guide is for an Ubuntu VPS with Nginx, Puma, Rails and PostgreSQL, using a custom domain.

## What to purchase and prepare

1. **Domain name**  
   Buy a domain such as `kishoricloset.com` from a registrar (GoDaddy, Namecheap, Google Domains, etc.).

2. **Ubuntu VPS**  
   Buy a VPS (2 GB RAM minimum, 4 GB preferred) from DigitalOcean, Hetzner, AWS Lightsail, or similar. Choose Ubuntu 22.04 or 24.04.

3. **DNS records**  
   In the domain registrar, create:

   | Type | Name | Value |
   | --- | --- | --- |
   | A | `@` | your VPS public IP |
   | A | `www` | your VPS public IP |

   Wait until the domain resolves to the VPS (`ping kishoricloset.com`).

4. **Email for SSL**  
   Let's Encrypt needs an email. Use `kishoricloset@gmail.com`.

You do **not** need Redis, Sidekiq, Elasticsearch, Stripe, Razorpay, or an email sending service.

---

## 1. Server packages

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

---

## 2. PostgreSQL

```bash
sudo -u postgres createuser -s kishori_closet
sudo -u postgres psql -c "ALTER USER kishori_closet WITH PASSWORD 'choose-a-strong-password';"
sudo -u postgres createdb -O kishori_closet kishori_closet_production
```

---

## 3. App user and code

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

---

## 4. Rails production environment

Create `/var/www/kishori_closet/.env` or export these in the systemd service:

```bash
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
APP_HOST=kishoricloset.com
SHIPPING_FEE=0
DATABASE_URL=postgres://kishori_closet:choose-a-strong-password@localhost/kishori_closet_production
RAILS_MASTER_KEY=paste-from-config-master-key
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

---

## 5. Puma systemd service

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
Environment=SHIPPING_FEE=0
Environment=DATABASE_URL=postgres://kishori_closet:PASSWORD@localhost/kishori_closet_production
Environment=RAILS_MASTER_KEY=YOUR_MASTER_KEY
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

Puma listens on `127.0.0.1:3000` if you set `PORT=3000`. By default it binds `0.0.0.0:3000`. Bind it to localhost by adding `Environment=PORT=3000` and in `config/puma.rb` you can add:

```ruby
bind "tcp://127.0.0.1:3000"
```

for production only, or leave the default and let Nginx proxy to 3000 while the firewall blocks public 3000.

---

## 6. Nginx

Create `/etc/nginx/sites-available/kishori_closet`:

```nginx
upstream kishori_closet {
  server 127.0.0.1:3000;
}

server {
  listen 80;
  server_name kishoricloset.com www.kishoricloset.com;
  return 301 https://kishoricloset.com$request_uri;
}

server {
  listen 443 ssl http2;
  server_name kishoricloset.com www.kishoricloset.com;

  root /var/www/kishori_closet/public;

  client_max_body_size 20M;

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  location / {
    try_files $uri @puma;
  }

  location @puma {
    proxy_pass http://kishori_closet;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Real-IP $remote_addr;
  }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/kishori_closet /etc/nginx/sites-enabled/
sudo nginx -t
```

---

## 7. HTTPS

First enable a temporary HTTP-only server block if Certbot needs port 80, then:

```bash
sudo certbot --nginx -d kishoricloset.com -d www.kishoricloset.com --email kishoricloset@gmail.com --agree-tos --redirect
sudo systemctl reload nginx
```

Certbot will insert the SSL certificate paths into the Nginx config.

---

## 8. Firewall

```bash
sudo ufw allow OpenSSH
sudo ufw allow "Nginx Full"
sudo ufw enable
```

---

## 9. After each update

```bash
cd /var/www/kishori_closet
git pull
bundle install
RAILS_ENV=production bundle exec rails db:migrate
RAILS_ENV=production bundle exec rails assets:precompile
sudo systemctl restart kishori_closet
```

---

## Local check before going live

1. `bin/dev` works on your machine.
2. Customer flow: sign up → shop → size → cart → checkout → UPI QR pay → confirm order.
3. Admin flow: login → products → stock → orders → status.
4. Then follow this guide on the VPS. Do not deploy automatically from this repository.
