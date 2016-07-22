class InviteMailer < ApplicationMailer

  default from: "info@ninayo.com"

  def existing_user_invite(invite)
    @invite = invite

    mail to: @invite.email
  end

  def new_user_invite(invite, user, url)
    @invite = invite
    @url = url
    @user = user
    mail to: @invite.email, subject: "#{@user.name.titleize} has invited you to NINAYO"
  end

end