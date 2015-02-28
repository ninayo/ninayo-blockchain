class User < ActiveRecord::Base

	has_many :ads
	has_many :ad_logs

	enum role: [:user, :vip, :admin]
	after_initialize :set_default_role, :if => :new_record?

	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
		:recoverable, :rememberable, :trackable, :validatable

	  # Virtual attribute for authenticating by either username or email
  	# This is in addition to a real persisted field like 'username'
	attr_accessor :login

	#validates :username, :email, :password, :password_confirmation, presence: true
	validates :username, presence: true

	def set_default_role
		self.role ||= :user
	end
end
