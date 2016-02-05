class UserLog < ActiveRecord::Base
	belongs_to :user
	validates :user, :action, presence: true


	def self.logins_per_day
		select("date(created_at) as created_at, count(*) as login_count")
			.group("date(created_at)")
			.order("date(created_at)")
	end

end
