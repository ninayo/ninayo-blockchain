# Primary Twilio controller, keep SMS-related stuff here if possible
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
    @alpha_id = 'NINAYOCOM'
    @outgoing_num = format_number(user.phone_number)
    @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'],
                                       ENV['TWILIO_AUTH_TOKEN'])

    @client.messages.create(from: @alpha_id,
                            to: @outgoing_num,
                            body: message)
  end
  # handle_asynchronously :send_sms

  def find_for_sms_reset
    if @u = User.find_by(phone_number: params[:reset_request][:phone_number])
      new_pw = @u.pin_reset
      message = "NINAYO.COM PIN yako imekuwa upya. PIN yako mpya ni #{new_pw}"
      send_sms(@u, message)
      redirect_to root_url, notice: (t 'views.common.sms_reset')
    else
      redirect_to new_user_password_path, alert: (t 'views.common.phone_not_found')
    end
  end

  def weekly_sms_prices(region_id = 5)
    sale_message = 'Tani 10,000 za mahindi zinapatikana mkoani Iringa kupitia '\
                   'www.ninayo.com kwa Shs 700 tu Kwa kilo. Tuma ujumbe '\
                   'kupitia 0623999538 Kwa maelezo zaidi'

    users_to_text = get_idle_recent_sellers(region_id)

    users_to_text.uniq.each { |u| send_sms(u, sale_message) }

    redirect_to prices_path, flash: { notice: 'Texted all relevant users' }
  end

  def harvest_reminder(region_id = 5)
    # random-sample 100 iringa people without login in 90-120 days
    reminder = 'Karibu tena, msimu wa mavuno umekaribia. '\
               'Jipatie bei nzuri zaidi kwa kutembelea www.NINAYO.com '\
               'au tuma ujumbe kupitia 0623999538'

    users_to_remind = recent_idle_users(region_id)

    users_to_remind.each { |user| send_sms(user, reminder) }
  end

  def format_number(num)
    num[0..3] == '+255' ? num : '+255' + num
  end

  private

  def get_idle_recent_sellers(region_id)
    ads = Ad.where('published_at >= ?', 30.days.ago)
            .where(region_id: region_id)
            .where(crop_type_id: 1)
            .where(ad_type: 'buy')
            .where(volume_unit: 2)

    users = []
    ads.each { |ad| users << ad.user unless ad.user.phone_number.blank? }

    users
  end

  def recent_idle_users(region_id)
    User.where(current_sign_in_at: 120.days.ago..90.days.ago)
        .where(region_id: region_id)
        .reject { |a| a.phone_number.blank? }
        .sample(100)
  end

  def client
    @client ||= Twilio::REST::Client.new
  end

  def message_attributes
    { to: params[:To],
      from: params[:From],
      body: params[:Body] }
  end
end
