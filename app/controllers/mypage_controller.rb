class MypageController < ApplicationController
	before_action :authenticate_user!

	def index
		#@ads = current_user.ads.where(:status => "published")
		@ads = current_user.ads.published
		@view = "current"

		respond_to do |format|
			format.html # index.html.erb
		end
	end

	def favorites
		# todo: filter out ads the user marked as bought
		@ads = current_user.favorites.published
		@view = "favorites"

		respond_to do |format|
			format.html 
		end
	end

	def archive
		@ads = current_user.ads.archived
		@view = "archived"

		respond_to do |format|
			format.html
		end
	end

	def bought
		@ads = current_user.bought_ads
		@view = "bought"

		respond_to do |format|
			format.html
		end
	end

end
