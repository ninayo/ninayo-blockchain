class AdsController < ApplicationController
	before_action :set_ad, only: [:show, :edit, :preview, :update, :destroy]
	before_action :authenticate_user!, :except => [:index, :show]

	respond_to :html

	def index
		@ads = Ad.published.includes(:crop_type).includes(:user).page(params[:page])
		respond_with(@ads)
	end

	def show
		respond_with(@ad)
	end

	def preview
		if current_user.id != @ad.user.id
			not_found
		end
	end

	def new
		@ad = Ad.new
		@crop_types = CropType.all
		respond_with(@ad)
	end

	def edit
		if @ad.archived?
			not_found
		end
		@crop_types = CropType.all
	end

	def create
		@ad = Ad.new(ad_params)
		#raise ad_params.to_y
		@ad.user = current_user
		@ad.crop_type_id = ad_params[:crop_type_id]

		if @ad.save
			redirect_to :action => "preview", :id => @ad.id
		else
			@crop_types = CropType.all
			render "new"
		end
	end

	def update
		@ad.update(ad_params)

		if @ad.published?
			redirect_to root_path
		else
			redirect_to :action => "preview", :id => @ad.id
		end
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
		params.require(:ad).permit(:user, :crop_type_id, :description, :price, :volume, :volume_unit, :village, :region, :position, :status)
	end
end
