class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    handle_redirect('devise.facebook_data', 'Facebook')
  end

  def handle_redirect(_session_variable, kind)
    #use session locale set earlier; use default if not available
    I18n.locale = session[:omniauth_login_locale] || I18n.default_locale

    user = User.find_for_oauth(request.env["omniauth.auth"])
    if user.persisted?
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end

  def user
    User.find_for_oauth(env['omniauth.auth'])
  end
end