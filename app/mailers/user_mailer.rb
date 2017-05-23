class UserMailer < ApplicationMailer
  default from: 'info@ninayo.com'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup_confirmation.subject
  #
  def signup_confirmation(user)
    @user = user

    mail to: user.email
  end

  def help_request(request)
    @request = request
    # just add onto this same to string with comma separations
    mail to: 'beck@ninayo.com'
  end
end
