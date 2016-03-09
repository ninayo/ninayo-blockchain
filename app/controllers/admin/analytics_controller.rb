class Admin::AnalyticsController < Admin::BaseController
	respond_to :html, :csv, :xls

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

	def users
		@users = User.user.includes(:ads).page(params[:page]).per(100)

		respond_to do |format|
			format.html
			format.csv { send_data @users.to_csv }
			format.xls
		end
	end

	def all_ads
		@ads = Ad.all

		respond_to do |format|
			format.xls
		end
	end



end
