class Users::RegistrationsController < Devise::RegistrationsController

  include Trackable

  after_action :track_update, only: [:update]

  def new
    super do
      @token = params[:invite_token]
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

  def build_login
    login = params[:user][:login].delete(" ")

    if is_valid_email?(login)
      resource.email, resource.phone_number = login, temp_phone
    elsif is_valid_phone_number?(login)
      resource.phone_number, resource.email = login, temp_email
    else
      #matched neither email or phone number, render error and return to super
    end
    resource.save
  end

  private

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
    track_event('User Management', 'New User', 'new account creation', "CREATED AN ACCOUNT: #{resource.email || resource.phone_number}")
  end

  def track_update
    track_event('User Management', 'User Update', 'account update', "UPDATE AN ACCOUNT: #{resource.email || resource.phone_number}")
  end

  def is_valid_email?(str)
    /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/.match(str) ? true : false
  end

  def is_valid_phone_number?(str)
    /^(\+|\d)[0-9]{8,9}$/.match(str) ? true : false
  end

  def temp_email
    "no_email#{rand(999999)}@ninayo.com"
  end

  def temp_phone
    "TEMPPHONE#{rand(9999999)}"
  end

end