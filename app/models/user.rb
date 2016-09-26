require 'net/http'

class User < ActiveRecord::Base

	#trackable inclusion goes here instead of controller, since devise+oauth tends to make google analytics choke
	include Trackable
	attr_accessor :login

	acts_as_messageable
	#skip sending confirmation email if we've assigned a user a temp email
	after_create :send_welcome_email, unless: Proc.new { self.email.nil? || self.email.include?("@ninayo.com") || self.email.blank? }
	#after_create :track_registration
	has_many :ads
	has_many :user_logs
	accepts_nested_attributes_for :ads

	has_many :ad_logs
	has_many :ratings
	belongs_to :region
	belongs_to :district
	belongs_to :ward

	has_many :favorite_ads
	has_many :favorites, through: :favorite_ads, source: :ad

	#invitation stuff
	has_many :invitations, :class_name => "Invite", :foreign_key => "receiver_id"
	has_many :sent_invites, :class_name => "Invite", :foreign_key => "sender_id"

	enum role: [:user, :vip, :admin]
	after_initialize :set_default_role, :if => :new_record?
	after_initialize :set_default_language, :if => :new_record?
	after_initialize :set_default_rating, :if => :new_record?

	#after_create :track_registration, :if => :new_record?

	validates :name, :phone_number, :agreement, presence: true, on: :save_ad
	validates :agreement, presence: true, :on => :create
	validates :phone_number, uniqueness: true, allow_nil: true
	validates :email, uniqueness: true, allow_blank: true, allow_nil: true 

	accepts_nested_attributes_for :ratings, allow_destroy: true

	#scope :seller_rating, -> { ratings.seller }


	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable, :omniauthable,
		:recoverable, :rememberable, :trackable, :validatable, :authentication_keys => { login: true }


	# def seller_score
	# 	if self.ratings.seller.exists?
	# 		self.ratings.seller.average(:score).round
	# 	else
	# 		0
	# 	end
	# end

	# def buyer_score
	# 	if self.ratings.buyer.exists?
	# 		self.ratings.buyer.average(:score).round
	# 	else
	# 		0
	# 	end
	# end

	# def self.find_first_by_auth_conditions(warden_conditions)
	#   conditions = warden_conditions.dup
	#   if login = conditions.delete(:login)
	#     where(conditions).where(["lower(phone_number) = :value OR lower(email) = :value", { :value => login.downcase }]).first
	#   else
	#     if conditions[:phone_number].nil?
	#       where(conditions).first
	#     else
	#       where(phone_number: conditions[:phone_number]).first
	#     end
	#   end
	# end

	def self.find_for_database_authentication(warden_conditions)
		conditions = warden_conditions.dup
		conditions[:email].downcase! if conditions[:email]

		if login = conditions.delete(:login)
			where(conditions.to_hash).where(["phone_number = :value OR email = :value", { :value => login.downcase }]).first
		elsif conditions.has_key?(:phone_number) || conditions.has_key?(:email)
			where(conditions.to_hash).first
		end
	end

	#so that mailboxer plays nice with devise
	def mailboxer_email(object)
		email
	end

	#overwrites built-in method, skips password req for oauth registration
	def password_required? 
		super && uid.blank?
	end

	def email_required?
		false
	end

	#overwrites built-in method, skip password req for oauth profile update
	def update_with_password(params, *options)
		if encrypted_password.blank?
			update_attributes(params, *options)
		else
			super
		end
	end

	def self.new_with_session(params, session)
		if session["devise.user_attributes"]
			#we use without_protection because we already trust the params hash here
			new(session["devise.user_attributes"], without_protection: true) do |user|
				user.attributes = params
				user.valid?
			end
		else
			#fall back to normal devise behavior
			super
		end
	end

	def self.find_for_oauth(auth)
		uid = auth.slice(:uid)

		#this is a weird hack to get an explicit image url
		#facebook graph API gives you a redirect url, but if you add redirect=false param
		#it will give you back some json including the actual url you need
		photo_url = URI.parse(auth.info.image)
		req = Net::HTTP::Get.new(photo_url.to_s + "?redirect=false") #we just append it here
		res = Net::HTTP.start(photo_url.host, photo_url.port) {|http|
			http.request(req)
		}
		#check to see if a user already exists. if it does, merge oauth data with existing user
		user = User.find_by_email(auth.info.email) || User.find_by_uid(auth.uid)
		if user
			user.uid = auth.uid
			user.name = auth.info.name
			user.photo_url = JSON.parse(res.body)["data"]["url"]
			return user
		end

		#new registration, so set properties of the new user. requested info determined in devise.rb
		where(uid: auth.uid, email: auth.info.email).first_or_create do |user|
			user.update(:uid => auth.uid,
									:name => auth.info.name,
									:email => auth.info.email || "no_email#{rand(999999)}@ninayo.com",
									:photo_url => JSON.parse(res.body)["data"]["url"],
									:agreement => true 
									)
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
		sum_sales_within_range(1.month.ago.beginning_of_month, 1.month.ago.end_of_month)
	end

	def sum_sales_this_month
		sum_sales_within_range(Time.now.beginning_of_month, Time.now.end_of_month)
	end

	def sum_sales_all_time
		sum_sales_within_range(self.created_at, Time.now)
	end

	def sum_sales_within_range(start_date, end_date) #return an integer, sum of all completed orders within range
		completed_ads = self.ads.where(:archived_at => start_date..end_date)
		return 0 if completed_ads.empty?
		completed_ads.map{ |ad| ad.final_price }.inject(:+)
	end
	
	# def track_registration
	# 	track_event('User Management', 'New User', 'new account creation', "CREATED AN ACCOUNT: #{current_user.email || current_user.phone_number}")
	# end

	def info_needed?
		phone_number.blank? || name.blank?
	end

	def location_needed?
		region_id.nil? || district_id.nil? || ward_id.nil? || village.blank?
	end

	protected

	def cleanup_temp
    self.phone_number[0..8] == ("TEMPPHONE") ? true : self.update(:email => nil)
  end

	def set_default_role
		self.role ||= :user
	end

	def set_default_email
		self.email ||=  "no_email#{rand(999999)}@ninayo.com"
	end

	def set_default_language
		self.language = "sw"
	end

	def set_default_rating
		self.seller_rating ||= 0
		self.buyer_rating ||= 0
	end

	def send_welcome_email
		UserMailer.signup_confirmation(self).deliver
	end
	
end
