class TrackSessionsController < Devise::SessionsController

	after_filter :after_login, :only => :create

	def after_login
		UserLog.create!(:user => current_user, :action => "login")
	end

end
