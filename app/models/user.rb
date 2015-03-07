class User < ActiveRecord::Base

	has_many :ads
	has_many :ad_logs
	has_many :favorite_ads
	has_many :favorites, through: :favorite_ads, source: :ad

	has_many :ratings

	enum role: [:user, :vip, :admin]
	after_initialize :set_default_role, :if => :new_record?

	accepts_nested_attributes_for :ratings, allow_destroy: true


	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
		:recoverable, :rememberable, :trackable, :validatable

	def set_default_role
		self.role ||= :user
	end
end
