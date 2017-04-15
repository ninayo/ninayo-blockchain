require 'net/http'

class User < ActiveRecord::Base
  attr_accessor :login

  acts_as_messageable
  # skip sending confirmation email if we've assigned a user a temp email
  after_create :send_welcome_email, unless: proc { email.nil? || email.include?('@ninayo.com') || email.blank? }

  has_many :ads
  has_many :user_logs
  has_many :ad_logs
  has_many :ratings

  accepts_nested_attributes_for :ads

  has_many :favorite_ads
  has_many :favorites, through: :favorite_ads, source: :ad

  has_many :comments, class_name: 'Comment', foreign_key: 'author_id'

  belongs_to :region
  belongs_to :district
  belongs_to :ward

  # invitation stuff
  has_many :invitations,       class_name: 'Invite',      foreign_key: 'receiver_id'
  has_many :sent_invites,      class_name: 'Invite',      foreign_key: 'sender_id'

  # call log stuff
  has_many :calls_made,        class_name: 'CallLog',     foreign_key: 'caller_id'
  has_many :calls_received,    class_name: 'CallLog',     foreign_key: 'receiver_id'

  has_many :texts_sent,        class_name: 'TextLog',     foreign_key: 'sender_id'
  has_many :texts_received,    class_name: 'TextLog',     foreign_key: 'receiver_id'

  has_many :whatsapp_sent,     class_name: 'WhatsappLog', foreign_key: 'sender_id'
  has_many :whatsapp_received, class_name: 'WhatsappLog', foreign_key: 'receiver_id'

  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, if: :new_record?
  after_initialize :set_default_language, if: :new_record?
  after_initialize :set_default_rating, if: :new_record?

  validates :name, :phone_number, :agreement, presence: true, on: :save_ad
  validates :name, :agreement, presence: true, on: :create
  validates :phone_number, uniqueness: true, allow_blank: true
  # validates :phone_number, numericality: true
  validates :email, uniqueness: { case_sensitive: false }, allow_blank: true

  accepts_nested_attributes_for :ratings, allow_destroy: true

  # scope :seller_rating, -> { ratings.seller }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, and :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => { login: true }

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    conditions[:email].downcase! if conditions[:email]

    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["phone_number = :value OR email = :value", { :value => login.downcase }]).first
    elsif conditions.key?(:phone_number) || conditions.key?(:email)
      where(conditions.to_hash).first
    end
  end

  # so that mailboxer plays nice with devise
  def mailboxer_email(object)
    email
  end

  # overwrites built-in method, skips password req for oauth registration
  def password_required?
    super && uid.blank?
  end

  def email_required?
    false
  end

  # overwrites built-in method, skip password req for oauth profile update
  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def self.new_with_session(params, session)
    if session['devise.user_attributes']
      # we use without_protection because we already trust the params hash here
      new(session['devise.user_attributes'], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      # fall back to normal devise behavior
      super
    end
  end

  def self.find_for_oauth(auth)
    # this is a weird hack to get an explicit image url
    # graph API gives you a redirect url, but if you add redirect=false param
    # it will give you back some json including the actual url you need
    photo_url = URI.parse(auth.info.image)
    req = Net::HTTP::Get.new(photo_url.to_s + '?redirect=false') # append here
    res = Net::HTTP.start(photo_url.host, photo_url.port) { |http| http.request(req) }
    # check to see if a user already exists, merge oauth data with existing user
    user = User.find_by_uid(auth.uid)
    if user
      user.update(gender: auth.extra.raw_info.gender) if user.gender.nil?
      user.update(birthday: auth.info.birthday) if user.birthday.nil?
      user.update(email: nil) if user.email.nil? || user.email.include?('no_email')
      user.uid = auth.uid
      user.name = auth.info.name
      user.photo_url = JSON.parse(res.body)['data']['url']
      return user
    end

    # new registration, set properties. requested info determined in devise.rb
    where(uid: auth.uid, email: auth.info.email).first_or_create do |u|
      u.update(uid: auth.uid,
               name: auth.info.name,
               email: auth.info.email || "no_email#{rand(999999999)}@ninayo.com",
               gender: auth.extra.raw_info.gender,
               birthday: auth.info.birthday,
               photo_url: JSON.parse(res.body)['data']['url'],
               agreement: true)
    end
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |user|
        csv << user.attributes.values_at(*column_names)
      end
    end
  end

  def sum_sales_last_month
    sum_sales_within_range(1.month.ago.beginning_of_month,
                           1.month.ago.end_of_month)
  end

  def sum_sales_this_month
    sum_sales_within_range(Time.now.beginning_of_month, Time.now.end_of_month)
  end

  def sum_sales_all_time
    sum_sales_within_range(created_at, Time.now)
  end

  def sum_sales_within_range(start_date, end_date) # sum all completed orders
    completed_ads = ads.where(archived_at: start_date..end_date)
    return 0 if completed_ads.empty?
    completed_ads.map(&:final_price).inject(:+)
  end

  def info_needed?
    phone_number.blank? || name.blank? || birthday.blank? || gender.blank?
  end

  def location_needed?
    region_id.nil? || district_id.nil? || ward_id.nil? || village.blank?
  end

  def birthday_needed?
    birthday.blank?
  end

  #first public-facing twilio implementation
  def sms_pw_reset
    #TODO: check to see if we've got a phone number first
    (redirect_to mypage_path, :flash => { error: "Please enter a phone number" }) if self.phone_number.blank?

    @twilio_number = ENV['TWILIO_NUMBER']
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

    new_pw = new_random_pin
    message = (I18n.locale == :sw ? "PIN yako imekuwa upya. PIN yako mpya ni #{new_pw}" : "Your PIN has been reset. Your new PIN is #{new_pw}")

    if self.reset_password(new_pw, new_pw)
      payload = @client.account.messages.create(
        :from => @twilio_number,
        :to => self.phone_number,
        :body => message
      )
      puts message.to
    else
      redirect_to reset_pw_path, :flash => { error: "Couldn't reset password, please try again" }
    end
  end

  protected

  def new_random_pin
    rand(0000..9999)
  end

  def cleanup_temp
    phone_number[0..8] == 'TEMPPHONE' ? true : update(email: nil)
  end

  def set_default_role
    self.role ||= :user
  end

  def set_default_email
    self.email ||=  "no_email#{rand(999999999)}@ninayo.com"
  end

  def set_default_language
    self.language = 'sw'
  end

  def set_default_rating
    self.seller_rating ||= 0
    self.buyer_rating ||= 0
  end

  def send_welcome_email
    UserMailer.signup_confirmation(self).deliver
  end
end
