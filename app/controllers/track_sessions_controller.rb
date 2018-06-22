class TrackSessionsController < Devise::SessionsController
  include Trackable
  require 'uri'
  
	after_filter :after_login, :only => :create

	def after_login
    track_event('User Management', 'User Login', 'account login', "ACCOUNT LOGIN: #{current_user.email}")
		UserLog.create!(:user => current_user, :action => "login")
	end
end
