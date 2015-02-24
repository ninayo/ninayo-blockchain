class User < ActiveRecord::Base

	has_many :ads

	enum role: [:user, :vip, :admin]
	after_initialize :set_default_role, :if => :new_record?

	  # Virtual attribute for authenticating by either username or email
  	# This is in addition to a real persisted field like 'username'
	attr_accessor :login

	validates :username, presence: true

	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
		:recoverable, :rememberable, :trackable, :validatable

	def set_default_role
		self.role ||= :user
	end
end
