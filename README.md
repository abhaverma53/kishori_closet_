# Kishori Closet

Simple fashion e-commerce for Kishori Closet, built with Ruby on Rails, PostgreSQL and Tailwind CSS. Payment is Cash on Delivery only.

## Local setup

Ruby 3.2.0, Rails 7.1, PostgreSQL 14 and Node 22 are expected.

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/dev
```

Open http://localhost:3000

### Sample logins

| Role | Email | Password |
| --- | --- | --- |
| Admin | admin@kishoricloset.com | password123 |
| Customer | abha@example.com | password123 |
| Customer | meera@example.com | password123 |

Admin area: http://localhost:3000/admin

### Tests

```bash
bin/rails test
```

### Shipping fee

Default shipping is ₹0. Change it with the `SHIPPING_FEE` environment variable or `config.shipping_fee` in `config/application.rb`.

### Order emails

After an order is placed, the customer receives a confirmation at their signup email, and every admin receives the order details at their registered email.

To send real Gmail messages, create a Google App Password for `kishoricloset@gmail.com` and start the server with:

```bash
SMTP_USERNAME=kishoricloset@gmail.com SMTP_PASSWORD=your-app-password bin/rails server
```

Without those variables, development writes emails to `tmp/mails` instead of sending them.

## Contact

- Email: kishoricloset@gmail.com
- Phone: +918722403536
