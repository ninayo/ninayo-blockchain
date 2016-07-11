class MessagesController < ApplicationController

  before_action :authenticate_user!

  def new
  end

  def create
    recipients = [User.find_by_id(params[:uid].keys.first)]
    conversation = current_user.send_message(recipients, params[:message][:body], params[:message][:subject]).conversation
    flash[:success] = "Message sent"
    redirect_to conversation_path(conversation)
  end

end