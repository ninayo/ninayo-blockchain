class AdsController < ApplicationController
	before_action :set_ad, only: [:show, :edit, :update, :destroy]

	respond_to :html

	def index
		@ads = Ad.all.order("created_at desc")
		respond_with(@ads)
	end

	def show
		respond_with(@ad)
	end

	def new
		@ad = Ad.new
		@crop_types = CropType.all
		respond_with(@ad)
	end

	def edit
	end

	def create
		@ad = Ad.new(ad_params)
		#raise ad_params.to_y
		@ad.user = current_user
		@ad.crop_type_id = ad_params[:crop_type_id]

		if @ad.save
			respond_with(@ad)
		else
			@crop_types = CropType.all
			render "new"
		end

	end

	def update
		@ad.update(ad_params)
		respond_with(@ad)
	end

	def destroy
		@ad.destroy
		respond_with(@ad)
	end

	private
		def set_ad
			@ad = Ad.find(params[:id])
		end

		def ad_params
			params.require(:ad).permit(:user, :crop_type_id, :description, :price, :volume, :volume_unit, :village, :region, :position)
		end
end
