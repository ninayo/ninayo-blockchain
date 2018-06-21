class SponsorController < ApplicationController
	include Trackable

	# Eventually handle multiple sponsorship ids here
	# We currenly only have one sponsor, so bruteforce the rendering layer
	def show
		render 'index'
	end

	def index
		#render 'index'
	end
	# track_event('Engagement & Acquisition',
  #                'Post Advert',
  #                "new #{@ad.ad_type} ad: #{@ad.region.name}",
  #                "NEW #{@ad.ad_type.upcase} AD: #{ga_info}")
end