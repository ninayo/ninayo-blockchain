class MessagesController < ApplicationController

  include Trackable

  before_action :authenticate_user!

  after_action :track_message, only: [:create]

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

  # def message_all
  #   redirect_to root_path unless current_user && current_user.admin?
  #   recipients = User.where(:region_id => nil, :created_at => Time.now.last_month.beginning_of_month..Time.now)

  #   recipients.each do |recipient|
  #     conversation = User.find_by_id(4).send_message(recipient, "Habari, asante kwa kujiunga na NINAYO.com. Tuanze na kuweka tangazo lako. Unaweza kuuza zao/mazao lolote/yoyote hapa NINAYO. \n Ni rahisi! Kuanza, bonyeza 'NINATAKA KUUZA'. Usisite kuuliza kama utakua na mwaswali yoyote au kama utahitaji msaada wa ziada.", "Kuwakaribisha kwa NINAYO!").conversation
  #   end

  #   redirect_to root_path, notice: "Announcement sent, delivery in progress"
  # end

  private

  def track_message
    track_event("Engagement & Acquisition", "Site message", "in-site message sent", "SEND MESSAGE TO AD")
  end

end