class TextMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    TextMessage.create(message_attributes)
    head :ok # need to have this or we run into errors with twilio api
  end

  def send_outgoing
    client.messages.create(
      to: to,
      from: from,
      body: body
    )
  end

  def send_sms(user, message)
    @twilio_number = ENV['TWILIO_NUMBER']
    @outgoing_num = format_number(user.phone_number)
    @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

    if @client.messages.create(from: @twilio_number, to: @outgoing_num, body: message)
      return true
    else
      return false
    end

  end
  #handle_asynchronously :send_sms
 
  def find_for_sms_reset
    @u = User.find_by(phone_number: params[:reset_request][:phone_number])

    if !@u.nil?
      new_pw = @u.pin_reset
      message = "NINAYO.COM PIN yako imekuwa upya. PIN yako mpya ni #{new_pw}"
      if send_sms(@u, message)
        redirect_to root_url, :flash => { notice: (I18n.locale == :en ? "Your PIN has been reset and sent to you via SMS" : "Nywila yako imewekwa upya na kupelekwa kupitia SMS") }
      else
        redirect_to new_user_password_path, flash: { alert: "Namba ya Simu haipatikani, tafadhali jaribu tena" }
      end
    else
      redirect_to(new_user_password_path, {:flash => { alert: (I18n.locale == :en ? "Phone number not found, please try again" : "Namba ya Simu haipatikani, tafadhali jaribu tena") } } )
    end
  end

  def weekly_sms_prices(region_id = 5)
    # TODO: param for region selection
    ads = Ad.where("published_at >= ?", 30.days.ago)
            .where(:region_id => 5)
            .where(:crop_type_id => 1)
            .where(:ad_type => "buy")
            .where(:volume_unit => "kilo")

    users_to_text = []

    ads.each do |ad|
      next if users_to_text.include?(ad.user)
      unless ad.user.phone_number.blank?
        users_to_text << ad.user
      end
    end

    sale_message = "Tani 10,000 za mahindi zinapatikana mkoani Iringa kupitia www.ninayo.com kwa Shs 700 tu Kwa kilo. Tuma ujumbe kupitia 0623999538 Kwa maelezo zaidi"

    users_to_text.each do |u|
      send_sms(u, sale_message)
    end

    redirect_to prices_path, flash: { notice: "Texted all relevant users" }

  end

  def harvest_reminder
    #random-sample 100 iringa people who haven't been to the site in 90-120 days
    reminder = "Karibu tena, msimu wa mavuno umekaribia. Jipatie bei nzuri zaidi kwa kutembelea www.NINAYO.com au tuma ujumbe kupitia 0623999538"

    users_to_remind = User.where(:current_sign_in_at => 120.days.ago..90.days.ago)
                          .where(:region_id => 5)
                          .reject{ |a| a.phone_number.blank? }
                          .sample(100)

    users_to_remind.each do |user|
      send_sms(user, reminder)
    end
  end
  helper_method :harvest_reminder

  def format_number(num)
    unless num[0..3] == "+255"
      num = "+255" + num
    end
  end

  private

  def client
    @client ||= Twilio::REST::Client.new
  end

  def message_attributes
    { to: params[:To],
      from: params[:From],
      body: params[:Body] }
  end
end
