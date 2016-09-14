class Users::RegistrationsController < Devise::RegistrationsController

  def new
    super do
      @token = params[:invite_token]
    end
  end

  def create
    build_login
    @user.referred_by_user_id = params[:ref]


    if @user.save
      cleanup_temp
      if params[:invite_token]
        @invite = Invite.find_by_token(params[:invite_token])
        @invite.update(:receiver_id => @user.id)
      end
      sign_in(:user, @user)
      redirect_to root_url, :notice => "Karibu!"
    else
      invalid_login
    end
  end

  def build_login
    @user = User.new(:agreement => true, :password => params[:user][:password])
    login = params[:user][:login].delete(" ")
    resource.referred_by_user_id = params[:ref]

    if is_valid_email?(login)
      @user.email, @user.phone_number = login, temp_phone
    elsif is_valid_phone_number?(login)
      @user.phone_number, @user.email = login, temp_email
    else
      #matched neither email or phone number, render error and return to super
    end
  end

  private

  def cleanup_temp
    return if @user.phone_number.nil? || @user.phone_number.blank?
    @user.phone_number[0..8] == ("TEMPPHONE") ? @user.update(:phone_number => nil) : @user.update(:email => nil)
  end

  def invalid_login
    @user.errors.clear
    @user.errors.add(:login, 'is invalid. Please enter a valid email or phone number.')
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