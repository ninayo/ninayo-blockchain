class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	before_action :set_locale
	before_action :configure_permitted_parameters, if: :devise_controller?

	def set_locale
		#I18n.locale = params[:locale] || I18n.default_locale
		I18n.locale = :en
		#I18n.locale = current_user.language if current_user
	end

	def not_found
		raise ActionController::RoutingError.new('Not Found')
	end

	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me, :name, :phonenumber, :region, :village, :language, :position) }
		devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
		devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :name, :phonenumber, :region, :village, :language, :position) }
	end
end
