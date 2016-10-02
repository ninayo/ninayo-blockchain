class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	before_action :set_locale
	protect_from_forgery with: :exception
	before_action :configure_permitted_parameters, if: :devise_controller?
	before_action :store_location

	# def set_locale
	# 	#I18n.locale = params[:locale] || I18n.default_locale
	# 	I18n.locale = :en
	# 	#I18n.locale = current_user.language if current_user
	# end


	#both this and redirect_back_or are required for mailboxer, in case a user has no messages
	rescue_from ActiveRecord::RecordNotFound do
		flash[:warning] = 'Resource not found'
		redirect_back_or root_path
	end

	def redirect_back_or(path)
		redirect_to request.referer || path
	end

	def not_found
		raise ActionController::RoutingError.new('Not Found')
	end

	def after_sign_in_path_for(resource)
		#root_path
		session[:previous_url]
	end

	protected

	def set_locale
		# if current_user
		# 	I18n.locale = current_user.language
		# else
			I18n.locale = params[:locale] || I18n.default_locale
		# end
	end

	def default_url_options(options = {})
		{ locale: I18n.locale }.merge options
	end

	def store_location
		# store last url as long as it isn't a /users path or a .json request

		session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/ || request.fullpath =~ /\/contact-info/ || request.fullpath =~ /\/terms/ ||request.fullpath.include?(".json")
	end

	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:login, :email, :phone_number, :password, :password_confirmation, :remember_me, :name, :phonenumber, :region, :village, :language, :lat, :lng, :agreement) }
		devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :email, :phone_number, :password, :remember_me) }
		devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :current_password, :name, :phone_number, :region_id, :village, :language, :lat, :lng, :language, :agreement) }
	end

	def admin_user?
		current_user && current_user.admin?
	end
	helper_method :admin_user?

	def vip_user?
		current_user && (current_user.vip? || current_user.admin?)
	end
	helper_method :vip_user?
end
