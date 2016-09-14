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

      invalid_login unless resource.save

      if params[:invite_token]
        @invite = Invite.find_by_token(params[:invite_token])
        @invite.update(:receiver_id => resource.id)
      end

      #cleanup_temp
    end
  end

  def build_login
    login = params[:user][:login].delete(" ")
    resource.referred_by_user_id = params[:ref]

    if is_valid_email?(login)
      resource.email, resource.phone_number = login, temp_phone
    elsif is_valid_phone_number?(login)
      resource.phone_number, resource.email = login, temp_email
    else
      puts "matched neither email nor phone"
      #matched neither email or phone number, render error and return to super
    end
    puts resource
  end

  private

  def cleanup_temp
    return if @user.phone_number.nil? || @user.phone_number.blank?
    @user.phone_number[0..8] == ("TEMPPHONE") ? @user.update(:phone_number => nil) : @user.update(:email => nil)
  end

  def invalid_login
    debugger
    @user.errors.clear
    @user.errors.add(:login, 'is invalid. Please enter a valid email or phone number.')
  end

  def is_valid_email?(str)
    puts "got valid email: #{str}"
    email_regex.match(str) ? true : false
  end

  def is_valid_phone_number?(str)
    puts "got valid phone #{str}"
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