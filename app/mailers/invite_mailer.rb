class InviteMailer < ApplicationMailer

  default from: "info@ninayo.com"

  def existing_user_invite(invite)
    @invite = invite

    mail to: @invite.email
  end

  def new_user_invite(invite, url)
    @invite, @url = invite, url

    mail to: @invite.email
  end

end