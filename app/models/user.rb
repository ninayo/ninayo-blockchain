class User < ActiveRecord::Base

	after_create :send_welcome_email
	has_many :ads
	has_many :user_logs
	accepts_nested_attributes_for :ads

	has_many :ad_logs
	has_many :ratings
	belongs_to :region

	has_many :favorite_ads
	has_many :favorites, through: :favorite_ads, source: :ad

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
	devise :database_authenticatable, :registerable,
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

	def self.to_csv
		CSV.generate do |csv|
			csv << column_names
			all.each do |user|
				csv << user.attributes.values_at(*column_names)
			end
		end
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
