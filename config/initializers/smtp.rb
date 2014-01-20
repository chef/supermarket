if Supermarket::Config.smtp
  Supermarket::Application.config.action_mailer.delivery_method = :smtp

  Supermarket::Application.config.action_mailer.smtp_settings = {
    address:              Supermarket::Config.smtp['address'],
    port:                 Supermarket::Config.smtp['port'],
    user_name:            Supermarket::Config.smtp['user_name'],
    password:             Supermarket::Config.smtp['password'],
    authentication:       'plain',
  }
end
