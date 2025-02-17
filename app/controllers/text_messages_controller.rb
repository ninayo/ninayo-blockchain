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
    @outgoing_num = format_number(user.phone_number)
    @alpha_id = @outgoing_num[0..1] == "+1" ? ENV['TWILIO_NUMBER'] : 'NINAYOCOM'
  
    @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'],
                                       ENV['TWILIO_AUTH_TOKEN'])

    begin
      @client.messages.create(from: @alpha_id,
                              to: @outgoing_num,
                              body: message)
    rescue Twilio::REST::RequestError => e
      puts e.message
    end
  end
  # handle_asynchronously :send_sms

  def find_for_sms_reset
    require 'uri'

    if @u = User.find_by(phone_number: params[:reset_request][:phone_number])
      new_pw = @u.pin_reset
      message = "NINAYO.COM PIN yako imekuwa upya. PIN yako mpya ni #{new_pw}"
      send_sms(@u, message)
      
      escapedPhone = URI.encode_www_form_component(params[:reset_request][:phone_number].to_s.strip)
      redirect_to "#{new_user_session_path}?user_login=#{escapedPhone}", notice: (t 'common.sms_reset')
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

  # def bartholomew_reminder
  #   bart_message = 'UJUMBE KUTOKA NINAYO.COM Bartholomew Kunzugala anahitaji kununua Mahindi na Alizeti. Wasiliana nae kwa namba 0756060561 kwa maelewano zaidi ASANTE' 

  #   national_sunflower_sellers = [15642, 21395, 15642, 22628, 22637, 22638, 22636, 22661, 22663, 22249, 22700, 22628, 22627, 22249, 22635, 22628, 22627, 22627, 22634, 22636, 22637, 23061]
  #   iringa_maize_sellers = [21035, 21036, 21037, 21397, 21398, 21466, 21486, 21595, 21674, 21686, 21780, 21785, 21790, 21792, 21793, 21795, 21798, 21799, 21803, 21805, 21809, 21810, 21818, 21820, 22299, 22301, 22305, 22307, 22308, 22309, 22318, 22319, 22320, 22321, 22323, 22332, 22334, 22335, 22336, 22337, 22338, 22339, 22342, 22345, 22353, 22357, 22364, 22416, 22432, 22433, 22456, 22566, 22569, 22621, 22623, 22625, 22626, 22627, 22630, 22631, 22632, 22633, 22634, 22635, 22640, 22641, 22652, 22653, 22654, 22655, 22656, 22657, 22658, 22659, 22660, 22662, 22664, 22716, 22732, 22733, 22742, 22743, 22744, 22745, 22747, 22748, 22749, 22750, 22751, 22752, 22754, 22757, 22758, 22759, 22760, 22761, 22762, 22763, 22764, 22765, 22767, 22770, 22866, 22934, 22936, 22937, 22940, 22945, 22948, 22949, 22950, 22951, 22963, 23058]

  #   bart_targets = national_sunflower_sellers + iringa_maize_sellers

  #   bart_targets.uniq[101..-1].each do |uid|
  #     user_to_text = User.find_by_id(uid)
  #     if user_to_text && !user_to_text.phone_number.blank?
  #       send_sms(user_to_text, bart_message)
  #     end
  #   end
  # end

  def format_number(num)
    num[0..3] == '+255' || num[0] == '+' ? num : '+255' + num
  end

  def envaya_endpoint
    head :ok

    return false unless validate_incoming_phone
    parse_incoming_and_validate_params # parse message params for info,

    find_or_create_new_sms_user # check user for previous registration,

    create_ad_from_sms # create ad
  end

  private

  def validate_incoming_phone
    params[:phone_number] == '0743195645'
  end

  def parse_incoming_and_validate_params
    @new_sms_ad = Ad.new(ad_type: 'sell')

    incoming_sms = params
    incoming_message = incoming_sms['message']

    return if incoming_message.blank?

    message_contents = incoming_message.gsub(', ', ' ').split(' ')

    if message_contents.length < 5 # check that the message is split properly
      message_contents = incoming_message.split(', ')
      sms_error unless message_contents.length == 5
    end

    # find the crop type
    crop_string = best_match(message_contents[0], CropType.all.map(&:name_sw)).titleize
    @new_sms_ad.crop_type_id = CropType.find_by(name_sw: crop_string).id

    # parse the volume and unit
    @new_sms_ad.volume = message_contents[1].to_i unless message_contents[1].to_i.zero?
    @new_sms_ad.volume_unit = Ad.volume_units[best_match(message_contents[2], Ad.volume_units.keys)] # ugly
    #temp fix, turn chanes to tanis
    #figure out how to match yml-string translations, maybe hashmap
    if @new_sms_ad.volume_unit == "chane"
      @new_sms_ad.volume_unit = "tonne"
    end

    # make sure the price is a number, strip off any characters

    @new_sms_ad.price = message_contents[3].to_i unless message_contents[3].to_i.zero?

    # find the region

    @new_sms_ad.region_id = Region.find_by(name: best_match(message_contents[4].titleize, Region.all.map(&:name))).id
    
    # account for dar being a phrase, figureout a better way to do this soon

    if message_contents[4].downcase == "dar"
      @new_sms_ad.region_id = Region.find_by_name("Dar es Salaam").id
      if message_contents[5..6].join(" ").downcase == "es salaam"
        message_contents.slice!(5..6)
      end
    end

    # chop off and reattach mjini/vijijni, do this better too

    if message_contents[6].downcase == "mjini" || message_contents[6] == "vijijini"
      message_contents[5] += " " 
      message_contents[5] += message_contents.slice!(6)
    end

    # find the district

    @new_sms_ad.district_id = District.find_by(name: best_match(message_contents[5].titleize, @new_sms_ad.region.districts.map(&:name))).id

    # get user name

    @new_user_name = message_contents[6..7].join(" ").strip

    @new_sms_ad.status = 1
  end

  # SAMPLE POST REQUEST FROM THE PHONE
  # Parameters: {
  #   "battery"=>"84", - current phone battery
  #   "from"=>"1234567890", - client phone number
  #   "log"=>"Server connection OK!\n", - current server log
  #   "message"=>"Sdfg qwerty", - incoming message
  #   "message_type"=>"sms", - duh
  #   "network"=>"WIFI", - currently connected network
  #   "now"=>"1501529648062", - time of relay (unix)
  #   "phone_id"=>"", - based on phone setting
  #   "phone_number"=>"8312776739", - number of OUR phone
  #   "phone_token"=>"", - also based on phone setting
  #   "power"=>"0", - is it plugged in or not
  #   "send_limit"=>"100",
  #   "settings_version"=>"0",
  #   "timestamp"=>"1501529648000", - timestamp on incoming message (unix)
  #   "version"=>"30" - current envaya version (don't see this changing)
  # }

  def find_or_create_new_sms_user
    @sms_sender = User.where(phone_number: params[:from]).first_or_create do |user|
      user.name ||= @new_user_name || "User-#{rand(1000)}"
      user.agreement = true
      user.password ||= SecureRandom.urlsafe_base64
      user.region_id ||= @new_sms_ad.region_id
      user.district_id ||= @new_sms_ad.region.districts.first.id
    end
    @sms_sender.name = @new_user_name unless (@new_user_name.nil? || (@new_user_name == @sms_sender.name))
    @sms_sender.save!
  end

  def create_ad_from_sms
    if @sms_sender.save!
      @new_sms_ad.user_id = @sms_sender.id
      if @new_sms_ad.save!
        head :ok
        send_twilio_response
      else
        sms_error
      end
    else
      sms_error
    end
  end

  def send_twilio_response
    # send a response through twilio about what happened
    message = "Asante kwa kutuma. Kiungo chako cha tangazo: http://www.ninayo.com/#{ad_path(@new_sms_ad.id)}"
    send_sms(@sms_sender, message)
  end

  def sms_error
    err_message = "Ujembe wako haujaeleweka, tafadhali tutumie Zao, #Kilo, Kilo/tani, Bei kwa kilo/tani, mkoa, jina"
    send_sms(@sms_sender, err_message)
  end

  def string_similarity(str1, str2)
    str1 = str1.downcase
    str2 = str2.downcase

    pairs1 = (0..str1.length - 2).collect{|i| str1[i, 2]}.reject { |pair| pair.include?(" ") }
    pairs2 = (0..str2.length - 2).collect{|i| str2[i, 2]}.reject { |pair| pair.include?(" ") }

    union = pairs1.size + pairs2.size

    intersection = 0

    pairs1.each do |p1|
      0.upto(pairs2.size - 1) do |i|
        if p1 == pairs2[i]
          intersection += 1
          pairs2.slice!(i)
          break
        end
      end
    end

    (2.0 * intersection) / union
  end

  def best_match(user_input, master_strings)
    confidence_hash = {}
    master_strings.each { |candidate| confidence_hash[candidate] = string_similarity(user_input, candidate) }
    confidence_hash.sort_by(&:last).last[0]
  end

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

  def incoming_sms_params
  end
end
