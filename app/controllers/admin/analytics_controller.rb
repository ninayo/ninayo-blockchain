class Admin::AnalyticsController < Admin::BaseController
	respond_to :html, :csv, :xls

	helper_method :ads_posted_this_month, :users_registered_this_month, :user_of_month

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
		@ads = Ad.all.includes(:region).includes(:crop_type)

		respond_to do |format|
			format.xls
		end
	end

	def ads_posted_this_month
		Ad.where(:created_at => Time.now.beginning_of_month..Time.now).count
	end

	def users_registered_this_month
		User.where(:created_at => Time.now.beginning_of_month..Time.now).count
	end

	#TODO: refactor this with an include/join so as not to be O(n)
	def user_of_month #returns highest-grossing user from last month
		best_sum = 0
		best_user = nil

		@users = User.where(:last_sign_in_at => Time.now.beginning_of_month..Time.now.end_of_month)
											.select{ |user| user.ads.length > 0 } #all users who've logged in within a month and posted an ad

		@users.each do |user|
			current_sum = user.sum_sales_within_range(Time.now.beginning_of_month, Time.now.end_of_month)
			if current_sum > best_sum
				best_sum, best_user = current_sum, user
			end
		end

		"#{best_user.name} - #{best_sum}/="

	end


end
