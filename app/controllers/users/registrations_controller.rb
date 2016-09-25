class Users::RegistrationsController < Devise::RegistrationsController

  def new
    super do
      @token = params[:invite_token]
    end
  end

  def create
    super do
      build_login
      resource.referred_by_user_id = params[:ref]

      if params[:invite_token]
        @invite = Invite.find_by_token(params[:invite_token])
        @invite.update(:receiver_id => resource.id)
      end
    end
    cleanup_temp
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
  end

  private

  def cleanup_temp
    return if resource.phone_number.nil?
    resource.phone_number[0..8] == ("TEMPPHONE") ? (resource.phone_number = nil) : (resource.email = nil)
  end

  def invalid_login
    resource.errors.clear
    resource.errors.add(:login, 'is invalid. Please enter a valid email or phone number.')
    redirect_to new_user_registration_url, :alert => "Simu au barua pepe imesajiliwa"
  end

  def is_valid_email?(str)
    email_regex.match(str) ? true : false
  end

  def is_valid_phone_number?(str)
    phone_regex.match(str) ? true : false
  end

  def email_regex
    /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/
  end

  def phone_regex
    /^(\+|\d)[0-9]{8,9}$/
  end

  def temp_email
    "no_email#{rand(999999)}@ninayo.com"
  end

  def temp_phone
    "TEMPPHONE#{rand(9999999)}"
  end

end