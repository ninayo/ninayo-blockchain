class ConversationsController < ApplicationController

  before_action :authenticate_user!
  before_action :get_mailbox
  before_action :get_conversation, except: [:index]
  before_action :get_box, only: [:index]

  #show method doesn't necessarily need contents, but mark_as_read makes things much easier to keep track of
  def show
    @receipts = @conversation.receipts_for(current_user)
    @conversation.mark_as_read(current_user)
  end

  def index
    if @box.eql? "inbox"
      @conversations = @mailbox.inbox
    elsif @box.eql? "sent"
      @conversations = @mailbox.sentbox
    else
      @conversations = @mailbox.trash
    end
    @conversations = @conversations
  end

  def reply
    current_user.reply_to_conversation(@conversation, params[:body])
    flash[:success] = (I18n.locale == :sw ? "Ujumbe wako umetumwa" : "Your message has been sent")
    redirect_to conversation_path(@conversation)
  end

  private

  def get_box
    if params[:box].blank? or !["inbox","sent","trash"].include?(params[:box])
      params[:box] = 'inbox'
    end
    @box = params[:box]
  end

  def get_mailbox
    @mailbox ||= current_user.mailbox
  end

  def get_conversation
    @conversation = @mailbox.conversations.find(params[:id])
  end

end
