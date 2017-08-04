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

  def mtenda_reminder
    message = 'UJUMBE KUTOKA NINAYO.COM Mtenda anahitaji kununua Mpunga. '\
              'Wasiliana nae kwa namba 0764-150312 kwa maelewano zaidi ASANTE' 

    targets = [22667,22668,22672,22775,22776,22777,22778,22779,22780,22781,22782,22783,22784,22785,22786,22787,22788,22867,22869,22870,22871,22873,22874,22875,22876,22877,22878,22879,22880,22881,22882,22883,22884,22885,22886,22887,22888,22889,22890,22891,22892,22893,22894,22895,22896,22897,22898,22899,22900,22901,22903,22904,22905,22906,22907,22909,22910,22913,22914,22915,22916,22917,22943,22995,22996,22997,22998,22999,23000,23001,23002,23003,23004,23005,23006,23007,23008,23009,23010,23011,23012,23013,23014,23015,23016,23017,23018,23019,23020,23021,23022,23023,23024,23025,23026,23027,23131,23132,23133,23134,23135,23136,23137,23138,23140,23141,23142,23143,23144,23145,23146,23147,23148,23149,23150,23151,23152,23153,23154,23155,23156,23192,23194,23197,23199,23201,23204,23205,23206,23207,23208,23209,23210,23211,23212,23214,23218,23220,23222,23224,23226,23233,23235,23238,23240,23242,23248,23249,23250,23251,23252,23253,23303,23304,23305,23306,23307,23308,23309,23310,23311,23312,23313,23314,23315,23316,23317,23327,23328,23329,23330,23331,23333,23345,23346,23347,23350,23351,23352,23353,23354,23355,23356,23357,23358,23359,23388,23389,23390,23391,23392,23455,23456,23457,23458,23459,23460,23461,23462,23463,23464,23465,23466,23467,23468,23469,23470,23471,23472,23473,23474,23475,23476,23477,23478,23479,23480,23481,23482,23483,23484,23485,23486,23501,23502,23503,23504,23505,23506,23507,23508,23509,23510,23511,23512,23513,23514,23515,23516,23517,23518,23519,23520,23521,23522,23523,23524,23525,23526,23527,23528,23529,23530,23531,23533,23534,23535,23536,23539,23541,23542,23544,23547,23549].first(128)

    targets.uniq.each do |uid|
      user_to_text = User.find_by_id(uid)
      if user_to_text && !user_to_text.phone_number.blank?
        send_sms(user_to_text, message)
      end
    end
  end

  def eddy_reminder
    message = 'UJUMBE KUTOKA NINAYO.COM Eddy Sanda anahitaji kununua Mahindi. '\
              'Wasiliana nae kwa namba 0756-993517 kwa maelewano zaidi ASANTE' 

    targets = [22792,22794,22795,22796,22797,22798,22799,22800,22801,22802,22805,22806,22807,22808,22809,22810,22811,22812,22813,22817,22830,23032,23033,23034,23035,23036,23037,23038,23039,23040,23159,23160,23165,23167,23168,23169,23170,23171,23172,23173,23174,23175,23176,23179,23180,23181,23186,23187,23188,23189,23191,23193,23195,23198,23200,23202,23215,23217,23219,23221,23223,23225,23227,23228,23229,23232,23234,23236,23239,23241,23243,23244,23245,23246,23247,23334,23335,23337,23338,23339,23340,23341,23342,23343,23344,23369,23370,23371,23372,23373,23375,23376,23377,23378,23381,23396,23397,23398,23399,23429,23431,23432,23433,23444,23445,23446,23448,23449,23450]

    targets.uniq.each do |uid|
      user_to_text = User.find_by_id(uid)
      if user_to_text && !user_to_text.phone_number.blank?
        send_sms(user_to_text, message)
      end
    end
  end

  def format_number(num)
    num[0..3] == '+255' ? num : '+255' + num
  end

  def envaya_endpoint
    head :ok

    validate_incoming_phone # validate incoming number, params[action] == "incoming"
    parse_incoming_and_validate_params # parse message params for info, 
                                       # validate that it's all doable and set vars
    find_or_create_new_sms_user # check user for previous registration,
                                # or register a new one

    create_ad_from_sms # create ad
    send_twilio_response # send a response through twilio
  end

  private

  def validate_incoming_phone
    sms_error unless (params[:phone_number] == "123456789")
  end

  def parse_incoming_and_validate_params
    @new_sms_ad = Ad.new(ad_type: "sell")

    incoming_sms = params
    incoming_user_number = incoming_sms["from"]
    incoming_message = incoming_sms["message"]

    message_contents = incoming_message.split(" ")
    
    if message_contents.length < 5 # check that the message is split properly, retry or fail
      message_contents = incoming_message.split(", ")
      sms_error unless message_contents.length == 5
    end

    #find the crop type
    crop_string = best_match(message_contents[0], CropType.all.map(&:name_sw)).titleize
    @new_sms_ad.crop_type_id = CropType.find_by(name_sw: crop_string).id

    #parse the volume and unit
    @new_sms_ad.volume = message_contents[1].to_i unless message_contents[1].to_i.zero?
    @new_sms_ad.volume_unit = Ad.volume_units[best_match(message_contents[2], Ad.volume_units.keys)] # ugly

    #make sure the price is a number, strip off any characters

    @new_sms_ad.price = message_contents[3].to_i unless message_contents[3].to_i.zero?

    #find the region

    @new_sms_ad.region_id = Region.find_by(name: best_match(message_contents[4].titleize, Region.all.map(&:name))).id

  end

  # SAMPLE POST REQUEST FROM THE PHONE
  # Parameters: { 
  #   "battery"=>"84", - current phone battery
  #   "from"=>"8312776739", - client phone number
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
      user.name ||= "User-#{rand(1000)}"
      user.agreement = true
      user.password ||= SecureRandom.urlsafe_base64
      user.region_id ||= @new_sms_ad.region_id
      user.district_id ||= @new_sms_ad.region.districts.first.id
    end
    @sms_sender.save!
  end

  def create_ad_from_sms
    if @sms_sender.save!
      @new_sms_ad.user_id = @sms_sender.id
      if @new_sms_ad.save!
        head :ok
      end
    else
      # didn't work
    end
  end

  def send_twilio_response
    # send a response through twilio about what happened
  end

  def sms_error
    return false
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
