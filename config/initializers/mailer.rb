unless Rails.env.test?
  smtp_user = ENV["SMTP_USERNAME"].presence
  smtp_pass = ENV["SMTP_PASSWORD"].presence

  if smtp_user && smtp_pass
    Rails.application.config.action_mailer.delivery_method = :smtp
    Rails.application.config.action_mailer.smtp_settings = {
      address: ENV.fetch("SMTP_ADDRESS", "smtp.gmail.com"),
      port: ENV.fetch("SMTP_PORT", "587").to_i,
      domain: "gmail.com",
      user_name: smtp_user,
      password: smtp_pass,
      authentication: :plain,
      enable_starttls_auto: true
    }
  end
end
