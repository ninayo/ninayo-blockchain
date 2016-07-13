class MessagesController < ApplicationController

  before_action :authenticate_user!

  def new
  end

  #right now this only gets one user out of the params, but recipients can be modified to support multiple users
  #conversation subject params are hardcoded in the view right now but this setup will take arbitrary input
  def create
    recipients = [User.find_by_id(params[:uid].keys.first)]
    conversation = current_user.send_message(recipients, params[:message][:body], params[:message][:subject]).conversation
    flash[:success] = "Message sent"
    redirect_to conversation_path(conversation)
  end
  #subject is hardcoded in messages/new.html.erb but we can replace the hidden with a normal field if we want
  #if someone really wants to modify the request they can set their own subject but whatever
end