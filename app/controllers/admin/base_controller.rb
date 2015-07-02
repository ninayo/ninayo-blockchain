class Admin::BaseController < ApplicationController
	layout "admin"
	before_action :authenticate_user!
	before_action :check_role

protected

	def check_role
		unless admin_user?
			redirect_to root_url, alert: "Permission denied"
		end
	end
end

