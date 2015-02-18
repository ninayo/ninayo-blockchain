class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_locale

	def set_locale
	  #I18n.locale = params[:locale] || I18n.default_locale
	  I18n.locale = :en
	  #I18n.locale = current_user.language if current_user
	end
end
