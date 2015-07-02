class Admin::AnalyticsController < Admin::BaseController
	respond_to :html

	def index
		@ads = Ad.all
		@users = User.all
	end
end