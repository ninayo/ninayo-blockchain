class AdsController < ApplicationController
	before_action :set_ad, only: [:show, :contact_info, :edit, :preview, :update, :destroy]
	before_action :get_ads, only: [:index, :map]
	before_action :authenticate_user!, :except => [:index, :map, :show]

	respond_to :html, :json

	def index
		@ads = @ads.includes(:crop_type)
					.includes(:user)
					.page(params[:page])

		@crop_type_id = params[:crop_type_id]
		@volume_min = params[:volume_min]
		@volume_max = params[:volume_max]
		@price_min = params[:price_min]
		@price_max = params[:price_max]
		@region_id = params[:region_id]
		@show_filter = cookies[:show_filter]

		@crop_types = CropType.all.order("name")
		@regions = Region.all.order("name")

		respond_to do |format|
			format.html # index.html.erb
			format.js { render json: @ads }
			format.json { render json: @ads }
		end
	end

	def map
		@ads = @ads.includes(:crop_type)
		@crop_types = CropType.all.order("name")
		@regions = Region.all.order("name")
	end

	def show
		unless @ad
			not_found
		else

			if current_user && (current_user.id == @ad.user.id || current_user.admin?)
				@ad_logs = @ad.ad_logs
			else
				# Todo: break out into method
				# note: Potential performance issue
				ad_log = AdLog.new
				ad_log.ad = @ad
				ad_log.user = current_user || nil
				# todo: Find a better way to assign event_type (use enum instead?)
				ad_log.event_type = EventType.first
				ad_log.save!
			end
			#respond_with(@ad)
		end
	end

	def contact_info
		# Todo: break out into method
		# note: Potential performance issue
		ad_log = AdLog.new
		ad_log.ad = @ad
		ad_log.user = current_user || nil
		# todo: Find a better way to assign event_type (use enum instead?)
		ad_log.event_type = EventType.last
		ad_log.save!

		@show_contact_info = true

		respond_to do |format|
			format.html { render "show" }
			format.js
		end
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

		if @ad.save
			if @ad.published?
				redirect_to ad_path(@ad)
			else
				redirect_to :action => "preview", :id => @ad.id
			end
		else
			@crop_types = CropType.all
			render "edit"
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

	def get_ads
		@ads = Ad.published
			.filter(params.slice(:crop_type_id))
			.filter(params.slice(:volume_min))
			.filter(params.slice(:volume_max))
			.filter(params.slice(:price_min))
			.filter(params.slice(:price_max))
			.filter(params.slice(:region_id))
			.order("published_at desc")
	end

	def ad_params
		params.require(:ad).permit(:user, :crop_type_id, :description, :price, :volume, :volume_unit, :village, :region_id, :position, :status, :lat, :lng)
	end
end
