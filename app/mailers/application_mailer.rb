# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAIL_FROM') { 'support@electron.com' }

  layout 'mailer'
end
