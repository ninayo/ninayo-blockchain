class InvitesController < ApplicationController

  include Trackable

  before_action :authenticate_user!

  after_action :track_invite, only: [:create]

  def index
    @invites = current_user.sent_invites
  end

  def create
    @invite = Invite.new(invite_params)
    @invite.sender_id = current_user.id
    @user = current_user

    if @invite.save

      if @invite.recipient != nil
        #inviting someone who's already in the system
        #do something, maybe send a reminder email
        #InviteMailer.existing_user_invite(@invite).deliver
      else
        #new user, send them the standard invite with a new token
        InviteMailer.new_user_invite(@invite, @user, new_user_registration_path(:invite_token => @invite.token)).deliver
      end
      #it worked, go home
      redirect_to root_url, notice: "Mwaliko kutumwa. Asante!"
    else
      #creating an invite failed for some reason
      redirect_to root_url, notice: "Huwezi kutuma ujumbe"
    end

  end

  private

  def track_invite
    track_event('INVITE', current_user.email)
  end

  def invite_params
    params.require(:invite).permit(:email)
  end

end
