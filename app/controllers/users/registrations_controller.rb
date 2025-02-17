class Users::RegistrationsController < Devise::RegistrationsController

  include Trackable

  after_action :track_update, only: [:update]

  def new
    respond_to do |format|
      format.html { 
        super do
          @token = params[:invite_token]
        end
      }
      format.json { render :status => phone_exists ? 200 : 403, :json => { :error => {"phone_exists" => phone_exists} } }
    end
  end

  def create
    super do
      build_login

      if params[:invite_token]
        @invite = Invite.find_by_token(params[:invite_token])
        @invite.update(:receiver_id => resource.id)
      end
      cleanup_temp
      track_registration
    end
  end

  def update_resource(resource, params)
    if !current_user.uid.nil?
      params.delete("current_password")
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end

  def build_login
    login = params[:user][:login].delete(" ")

    if valid_email?(login)
      resource.email, resource.phone_number = login, temp_phone
    elsif valid_phone_number?(login)
      format_phone_number(login)
      resource.phone_number, resource.email = login, temp_email
    else
      #matched neither email or phone number, render error and return to super
    end
    resource.save
  end

  private

  def phone_exists
    return !User.where('phone_number LIKE ?', "%#{params['phone'].strip}").blank?
  end

  def cleanup_temp
    return if @user.phone_number.nil? || @user.phone_number.blank?
    resource.phone_number[0..8] == ("TEMPPHONE") ? @user.update(:phone_number => nil) : @user.update(:email => nil)
  end

  def invalid_login
    resource.errors.clear
    resource.errors.add(:login, 'is invalid. Please enter a valid email or phone number.')
    redirect_to new_user_registration_url, :alert => "Simu au barua pepe imesajiliwa"
  end

  def track_registration
    track_event('User Management', 'New User', 'new account creation', "CREATED AN ACCOUNT: #{resource.email || resource.phone_number} PARAMS: #{gtm_info}")
  end

  def track_update
    track_event('User Management', 'User Update', 'account update', "UPDATE AN ACCOUNT: #{resource.email || resource.phone_number} PARAMS: #{gtm_info}")
  end

  def gtm_info
    {
      utm_source: params[:utm_source],
      utm_medium: params[:utm_medium],
      utm_campaign: params[:utm_campaign],
      gclid: params[:gclid],
      cid: google_analytics_client_id
    }
  end

  def valid_email?(str)
    /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/.match(str) ? true : false
  end

  def valid_phone_number?(str)
    str.gsub!('+255', '')
    /^(\+|\d)[0-9]{8,9}$/.match(str) ? true : false
  end

  def format_phone_number(num)
    if num.length == 9
      num = ('0' + num)
    end
  end

  def temp_email
    "no_email#{rand(9999999999)}@ninayo.com"
  end

  def temp_phone
    "TEMPPHONE#{rand(9999999)}"
  end
end
