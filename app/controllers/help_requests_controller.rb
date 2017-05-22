# handle help requests submitted through the 'need help' link
class HelpRequestsController < ApplicationController
  before_action :open_help_requests, only: [:index]
  before_action :authenticate_admin, only: [:index]

  def new; end

  def create
    @request = HelpRequest.new(help_params)
    @request.user_id = current_user.id
    if @request.save
      redirect_to root_url, notice: 'Your help request has been received, '\
                                    'we will respond as quickly as possible'
    else
      redirect_to new_help_request_path,
                  alert: @request.errors.full_messages.to_sentence
    end
  end

  def close_help_request
    request = HelpRequest.find(params[:id])
    redirect_to root_url if request.nil? || request.closed
    request.update(closed: true)
    redirect_to help_requests_path, notice: "Help ticket closed"
  end

  def index; end

  private

  def authenticate_admin
    redirect_to root_url unless current_user && current_user.admin?
  end

  def open_help_requests
    @help_requests = HelpRequest.where(closed: false)
                                .order('created_at desc')
  end

  def closed_help_requests
    @help_requests = HelpRequest.where(closed: true)
                                .order('created_at desc')
  end

  def help_params
    params.require(:help_request).permit(:request_type,
                                         :body,
                                         :phone_number,
                                         :email)
  end
end
