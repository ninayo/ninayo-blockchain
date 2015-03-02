class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	before_action :set_locale
	before_action :configure_permitted_parameters, if: :devise_controller?
	after_action :store_location

	def set_locale
		#I18n.locale = params[:locale] || I18n.default_locale
		I18n.locale = :en
		#I18n.locale = current_user.language if current_user
	end

	def not_found
		raise ActionController::RoutingError.new('Not Found')
	end

	def after_sign_in_path_for(resource)
		session[:previous_url] || root_path
	end

	protected

	def store_location
		# store last url as long as it isn't a /users path
		session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/
	end

	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :remember_me, :name, :phonenumber, :region, :village, :language, :position) }
		devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:email, :password, :remember_me) }
		devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :current_password, :name, :phonenumber, :region, :village, :language, :position) }
	end
end
