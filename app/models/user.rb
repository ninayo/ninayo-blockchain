class User < ActiveRecord::Base

	has_many :ads
	accepts_nested_attributes_for :ads

	has_many :ad_logs
	has_many :ratings
	belongs_to :region

	has_many :favorite_ads
	has_many :favorites, through: :favorite_ads, source: :ad

	enum role: [:user, :vip, :admin]
	after_initialize :set_default_role, :if => :new_record?

	validates :name, :email, :phone_number, presence: true, on: :save_ad

	accepts_nested_attributes_for :ratings, allow_destroy: true

	scope :seller_rating, -> { ratings.seller }


	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
		:recoverable, :rememberable, :trackable, :validatable

	def set_default_role
		self.role ||= :user
	end

	def seller_score
		if self.ratings.seller.exists?
			self.ratings.seller.average(:score).round
		else
			0
		end
	end

	def buyer_score
		if self.ratings.buyer.exists?
			self.ratings.buyer.average(:score).round
		else
			0
		end
	end
end
