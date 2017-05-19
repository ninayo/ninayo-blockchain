class HelpRequestsController < ApplicationController
  before_action :authenticate_admin, only: :show
  before_filter { redirect_to root_url unless current_user.admin? }

  def new
    @user = current_user
  end

  def create
    @request = HelpRequest.new(help_params)
    @request.user_id = current_user.id
    if @request.save
      redirect_to root_url, notice: 'Your help request has been received, '\
                                    'we will respond as quickly as possible'
    else
      redirect_to new_help_request_path, alert: @request.errors.full_messages.to_s
    end
  end

  def help_params
    params.require(:request).permit(:request_type, :body, :phone_number, :email)
  end
end
