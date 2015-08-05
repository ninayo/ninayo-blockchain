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
end