class MypageController < ApplicationController
	before_action :authenticate_user!

	def index
		@ads = current_user.ads.where(:status => "published")
		@view = "current"

		respond_to do |format|
			format.html # index.html.erb
		end
	end

	def favorites
		@ads = current_user.favorites
		@view = "favorites"

		respond_to do |format|
			format.html 
		end
	end

	def archive
		@ads = current_user.ads.where(:status => "archived")
		@view = "archived"

		respond_to do |format|
			format.html
		end
	end

end
