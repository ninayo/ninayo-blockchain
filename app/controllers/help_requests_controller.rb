# handle help requests submitted through the 'need help' link
class HelpRequestsController < ApplicationController
  before_action :open_help_requests, only: [:index]
  before_action :closed_help_requests, only: [:closed_index]
  before_action :authenticate_admin, only: [:index]

  def new; end

  def create
    @request = HelpRequest.new(help_params)
    @request.user_id = (current_user && current_user.id ? current_user.id : nil)
    if @request.save
      redirect_to root_url, notice: 'Ombi lako iliwasilishwa kwa ufanisi.'\
                                    'Tutawasiliana na wewe hivi karibuni'
    else
      redirect_to new_help_request_path,
                  alert: @request.errors.full_messages.to_sentence
    end
  end

  def close_help_request
    request = HelpRequest.find(params[:id])
    redirect_to root_url if request.nil? || request.closed
    request.update(closed: true)
    redirect_to help_requests_path, notice: 'Ombi kutatuliwa'
  end

  def index; end

  def closed_index
    render :closed_index
  end

  private

  def authenticate_admin
    redirect_to root_url unless admin_user?
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
