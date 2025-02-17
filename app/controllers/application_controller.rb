class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :block_ip_addresses
  before_action :set_locale
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_location

  # this and redirect_back_or are required for mailboxer, in case of no messages
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
    redirect = session[:previous_url]
    # Make sure redirect isn't to sms reset page, if sign in succesful. Also don't allow nil
    return redirect unless redirect.nil? || redirect[0..9] == "/sms_reset"
    root_path
  end

  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def store_location
    # store last url as long as it isn't a /users path or a .json request
    session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/ || request.fullpath =~ /\/messages\/new/ || request.fullpath =~ /\/prices\/dar_new/ || request.fullpath =~ /\/prices\/iringa_new/ || request.fullpath =~ /\/prices\/mbeya_new/ || request.fullpath =~ /\/contact-info/ || request.fullpath =~ /\/terms/ || request.fullpath =~ /\/admin/ || request.fullpath.include?(".json")
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:login, :email, :phone_number, :password, :password_confirmation, :remember_me, :name, :phonenumber, :region, :village, :language, :lat, :lng, :agreement) }
    devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:login, :email, :phone_number, :password, :remember_me) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :current_password, :name, :phone_number, :region_id, :village, :language, :lat, :lng, :language, :agreement) }
  end

  def admin_user?
    current_user && current_user.admin?
  end
  helper_method :admin_user?

  def vip_user?
    current_user && (current_user.vip? || current_user.admin?)
  end
  helper_method :vip_user?

  def block_ip_addresses
    suckas_to_ban = ip_range('164.132.161') +
                    ip_range('164.132.162') +
                    ip_range('51.255.65') +
                    ip_range('51.255.71') +
                    ip_range('51.255.214') +
                    ip_range('217.182.132') +
                    ip_range('137.74.207') +
                    ['5.9.147.133', '213.133.111.165', '177.133.108.96', '46.217.121.80', '76.97.196.137', '136.243.36.90', '151.80.44.115', '148.251.2.2']

    head :bad_request if suckas_to_ban.include?(current_ip_address)
  end

  def current_ip_address
    request.ip || request.env['HTTP_X_REAL_IP'] || request.env['REMOTE_ADDR']
  end

  def ip_range(first_three)
    (0..255).to_a.map { |suf| first_three + '.' + suf.to_s }
  end
end
