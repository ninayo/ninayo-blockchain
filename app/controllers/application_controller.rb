class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	before_action :configure_permitted_parameters, if: :devise_controller?
	before_action :store_location
	before_action :set_locale

	# def set_locale
	# 	#I18n.locale = params[:locale] || I18n.default_locale
	# 	I18n.locale = :en
	# 	#I18n.locale = current_user.language if current_user
	# end

	def not_found
		raise ActionController::RoutingError.new('Not Found')
	end

	def after_sign_in_path_for(resource)
		session[:previous_url] || root_path
	end

	protected

	def set_locale
		# I18n.locale = :en
		# if params[:locale]
		# 	I18n.locale = params[:locale]
		# els
		# if current_user
		# 	I18n.locale = current_user.language
		# else
		# 	I18n.default_locale
		# end

		#I18n.locale = params[:locale] || I18n.default_locale
		I18n.locale = current_user.language if current_user
	end

	def store_location
		# store last url as long as it isn't a /users path or a .json request

		session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/ || request.fullpath =~ /\/terms/ ||request.fullpath.include?(".json")
	end

	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :remember_me, :name, :phonenumber, :region, :village, :language, :lat, :lng, :agreement) }
		devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:email, :password, :remember_me) }
		devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :current_password, :name, :phone_number, :region_id, :village, :language, :lat, :lng, :language, :agreement) }
	end
end
