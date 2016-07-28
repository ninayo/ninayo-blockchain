class MessagesController < ApplicationController

  before_action :authenticate_user!

  def new
  end

  #right now this only gets one user out of the params, but recipients can be modified to support multiple users
  #conversation subject params are hardcoded in the view right now but this setup will take arbitrary input
  def create
    recipients = User.where(id: params['recipients']) || [User.find_by_id(params[:uid].keys.first)]
    conversation = current_user.send_message(recipients, params[:message][:body], params[:message][:subject]).conversation
    flash[:success] = "Message sent"
    redirect_to conversation_path(conversation)
  end
  #subject is hardcoded in messages/new.html.erb but we can replace the hidden with a normal field if we want
  #if someone really wants to modify the request they can set their own subject but whatever

  def admin_message
    redirect_to root_path unless current_user && current_user.admin?
  end

  def message_all
    redirect_to root_path unless current_user && current_user.admin?
    recipients = User.all
    conversation = current_user.send_message(recipients, "Je, unataka 500,000 / = kusherehekea na juu ya Nane Nane? Bonyeza 'Waharike Marafiki' na kisha kuandika katika barua pepe ya rafiki yako na wanakijiji wenzake. NINAYO mtumiaji ambaye inahusu watumiaji wengi wapya atashinda Laki Tano ya Tigo Pesa hii Nane Nane!", "500,000/= NANE NANE Tuzo!").conversation
    redirect_to root_path, notice: "Announcement sent, delivery in progress"
  end

end