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
      redirect_to root_url, notice: (t 'common.sms_reset')
    else
      redirect_to new_user_password_path, alert: (t 'common.phone_not_found')
    end
  end

  def weekly_sms_prices(region_id = 5)
    sale_message = 'Tani 10,000 za mahindi zinapatikana mkoani Iringa kupitia '\
                   'www.ninayo.com kwa Shs 700 tu Kwa kilo. Tuma ujumbe '\
                   'kupitia 0623999538 Kwa maelezo zaidi'

    users_to_text = get_idle_recent_sellers(region_id)

    users_to_text.each { |u| send_sms(u, sale_message) }

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

  def bartholomew_reminder
    bart_message = 'UJUMBE KUTOKA NINAYO.COM Bartholomew Kunzugala anahitaji kununua Mahindi na Alizeti. Wasiliana nae kwa namba 0756060561 kwa maelewano zaidi ASANTE' 

    national_sunflower_sellers = [15642, 21395, 15642, 22628, 22637, 22638, 22636, 22661, 22663, 22249, 22700, 22628, 22627, 22249, 22635, 22628, 22627, 22627, 22634, 22636, 22637, 23061]
    iringa_maize_sellers = [21035, 21036, 21037, 21397, 21398, 21466, 21486, 21595, 21674, 21686, 21780, 21785, 21790, 21792, 21793, 21795, 21798, 21799, 21803, 21805, 21809, 21810, 21818, 21820, 22299, 22301, 22305, 22307, 22308, 22309, 22318, 22319, 22320, 22321, 22323, 22332, 22334, 22335, 22336, 22337, 22338, 22339, 22342, 22345, 22353, 22357, 22364, 22416, 22432, 22433, 22456, 22566, 22569, 22621, 22623, 22625, 22626, 22627, 22630, 22631, 22632, 22633, 22634, 22635, 22640, 22641, 22652, 22653, 22654, 22655, 22656, 22657, 22658, 22659, 22660, 22662, 22664, 22716, 22732, 22733, 22742, 22743, 22744, 22745, 22747, 22748, 22749, 22750, 22751, 22752, 22754, 22757, 22758, 22759, 22760, 22761, 22762, 22763, 22764, 22765, 22767, 22770, 22866, 22934, 22936, 22937, 22940, 22945, 22948, 22949, 22950, 22951, 22963, 23058]

    bart_targets = national_sunflower_sellers + iringa_maize_sellers

    bart_targets.uniq[52..-1].each do |uid|
      user_to_text = User.find_by_id(uid)
      if user_to_text && !user_to_text.phone_number.blank?
        send_sms(user_to_text, bart_message)
      end
    end
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

    users.uniq
  end

  def recent_idle_users(region_id)
    User.where(current_sign_in_at: 120.days.ago..60.days.ago)
        .reject { |a| a.phone_number.blank? }
        .sample(500)
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
