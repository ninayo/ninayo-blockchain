class Admin::AnalyticsController < Admin::BaseController
	respond_to :html

	def index
		@ads = Ad.all
		@users = User.all
	end

	def ads_per_day
		@ads_per_day = Ad.ads_per_day
		@transactions_per_day = Ad.transactions_per_day
	end

	def logins_per_day
		@logins_per_day = UserLog.logins_per_day
		if params[:start_date]
			@start_date = params[:start_date].to_date
		else
			@start_date = (DateTime.now - 30.days).to_date
		end 

		if params[:end_date]
			@end_date = params[:end_date].to_date
		else
			@end_date = DateTime.now.to_date
		end 
	end
end