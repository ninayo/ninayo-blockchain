class ConversationsController < ApplicationController

  before_action :authenticate_user!
  before_action :get_mailbox
  before_action :get_conversation, except: [:index]

  #show method doesn't necessarily need contents, but mark_as_read makes things much easier to keep track of
  def show
    @receipts = @conversation.receipts_for(current_user)
    @conversation.mark_as_read(current_user)
  end

  def index
    #uncomment pagination if we want to use something like kaminari
    @conversations = @mailbox.inbox#.paginate(page: params[:page], per_page: 10)
  end

  def reply
    current_user.reply_to_conversation(@conversation, params[:body])
    flash[:success] = "Reply sent"
    redirect_to conversation_path(@conversation)
  end

  private

  def get_mailbox
    @mailbox ||= current_user.mailbox
  end

  def get_conversation
    @conversation = @mailbox.conversations.find(params[:id])
  end

end
