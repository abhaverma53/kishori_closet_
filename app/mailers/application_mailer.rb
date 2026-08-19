class ApplicationMailer < ActionMailer::Base
  default from: "Kishori Closet <#{KishoriCloset::CONTACT_EMAIL}>"
  layout "mailer"
  helper ApplicationHelper
end
