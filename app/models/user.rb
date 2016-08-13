require 'net/http'

class User < ActiveRecord::Base

	acts_as_messageable

	after_create :send_welcome_email
	has_many :ads
	has_many :user_logs
	accepts_nested_attributes_for :ads

	has_many :ad_logs
	has_many :ratings
	belongs_to :region

	has_many :favorite_ads
	has_many :favorites, through: :favorite_ads, source: :ad

	#invitation stuff
	has_many :invitations, :class_name => "Invite", :foreign_key => "receiver_id"
	has_many :sent_invites, :class_name => "Invite", :foreign_key => "sender_id"

	enum role: [:user, :vip, :admin]
	after_initialize :set_default_role, :if => :new_record?
	after_initialize :set_default_language, :if => :new_record?
	after_initialize :set_default_rating, :if => :new_record?

	validates :name, :email, :phone_number, :agreement, presence: true, on: :save_ad
	validates :agreement, presence: true, :on => :create

	accepts_nested_attributes_for :ratings, allow_destroy: true

	#scope :seller_rating, -> { ratings.seller }


	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable, :omniauthable,
		:recoverable, :rememberable, :trackable, :validatable


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

	#so that mailboxer plays nice with devise
	def mailboxer_email(object)
		email
	end

	#overwrites built-in method, skips password req for oauth registration
	def password_required? 
		super && uid.blank?
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

protected

	def set_default_role
		self.role ||= :user
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
