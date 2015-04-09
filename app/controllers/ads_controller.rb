class AdsController < ApplicationController
	before_action :set_ad, only: [:show, :infopanel, :contact_info, :edit, :preview, :archive, :update, :destroy, :rate_seller, :save_buy_info]
	before_action :get_ads, only: [:index, :map]
	before_action :authenticate_user!, :except => [:index, :map, :show]

	respond_to :html, :json

	def index
		@ads = @ads.includes(:crop_type)
					.includes(:user)
					.includes(:region)
					.page(params[:page])

		@crop_types = CropType.all.order("id")
		@regions = Region.all.order("name")

		respond_to do |format|
			format.html { render layout: 'startpage' } # index.html.erb
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
		if !@ad
			not_found
		elsif @ad.archived?
			not_found
		else
			if current_user && (current_user.id == @ad.user.id || current_user.admin?)
				@ad_logs = @ad.ad_logs
							.includes(:event_type)
							.includes(:user)
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

	def infopanel
		render "_infopanel", layout: false
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
		#@ad.user = current_user
		@show_contact_info = true;
		@preview = true;
	end

	def new
		@ad = Ad.new
		@ad.user = current_user
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
		current_user.update(user_params)
		@ad = Ad.new(ad_params)
		@ad.user = current_user
		#@ad.user.update(user_params)
		@ad.crop_type_id = ad_params[:crop_type_id]

		if @ad.save
			if @ad.save
				redirect_to :action => "preview", :id => @ad.id
			else
				@crop_types = CropType.all
				@ad.user = current_user
				render "new"
			end
		else
			@ad.user = current_user
			@crop_types = CropType.all
			render "new"
		end
	end


	def update
		@ad.update(ad_params)
		@ad.user.update(user_params)

		if @ad.save(context: :save_ad)
			if @ad.published?
				# if user have no location info, update with the ads
				update_user_location
				redirect_to ad_path(@ad)
			elsif @ad.archived?

				if @ad.buyer_id
					@rating = Rating.new(:rater_id => @ad.user_id, :ad => @ad, :score => params[:score], :role => "buyer", :user_id => @ad.buyer_id)

					if @rating.save
						redirect_to mypage_archive_path, notice: "Your ad have been archived!"
					else
						@buyers = buyers(@ad)
						render "archive"
					end
				else
					redirect_to mypage_archive_path, notice: "Your ad have been archived!"
				end
			else
				redirect_to :action => "preview", :id => @ad.id
			end
		else

			if @ad.archived?
				@buyers = buyers(@ad)
				render "archive"
			else
				@crop_types = CropType.all
				render "edit"
			end
		end

	end

	def destroy
		@ad.destroy
		respond_with(@ad)
	end

	# Add and remove favorite recipes
	# for current_user
	def favorite
		type = params[:type]
		@ad = Ad.find(params[:ad_id])
		if type == "favorite"
			current_user.favorites << @ad
			redirect_to :back, notice: "You added #{@ad.title} to your favorites"

		elsif type == "unfavorite"
			current_user.favorites.delete(@ad)
			redirect_to :back, notice: "You removed #{@ad.title} from favorites"

		else
			# Type missing, nothing happens
			redirect_to :back, notice: 'Nothing happened.'
		end
	end

	def archive
		if current_user && current_user.id == @ad.user_id
			if @ad.archived?
				redirect_to root_path, notice: "This ad is already archived"
			end
			@buyers = buyers(@ad)
		else
			not_found
		end
	end

	def rate_seller
		@rating = Rating.new
	end

	def save_buy_info
		@ad.update(ad_params)

		if @ad.save(context: :save_buyer_info)

			# Save rating
			@rating = Rating.new(:rater_id => current_user.id, :ad => @ad, :score => params[:score], :role => "seller", :user_id => @ad.user_id)

			if @rating.save
				redirect_to root_path, notice: "Thanks for rating the seller!"
			else
				render "rate_seller"
			end
		else
			render "rate_seller"
		end
	end


private

	def update_user_location
		if !@ad.user.lat && @ad.lat
			@ad.user.lat = @ad.lat
		end
		if !@ad.user.lng && @ad.lng
			@ad.user.lng = @ad.lng
		end
		if !@ad.user.region_id && @ad.region_id
			@ad.user.region_id = @ad.region_id
		end
		if !@ad.user.village && @ad.village
			@ad.user.village = @ad.village
		end

		@ad.user.save
	end

	def buyers(ad)
		arr = []
		AdLog.where(:ad => ad, :event_type_id => 2).each do |a|
			arr.push(a.user)
		end
		buyers = arr.uniq{|u| u.id}
		buyers = buyers.sort! { |a,b| a.name.downcase <=> b.name.downcase }
	end

	def set_ad
		@ad = Ad.find(params[:id])
	end

	def get_ads
		@ad_type = params[:ad_type] || "sell"
		@crop_type_id = params[:crop_type_id]
		@volume_min = params[:volume_min]
		@volume_max = params[:volume_max]
		@price_min = params[:price_min]
		@price_max = params[:price_max]
		@region_id = params[:region_id]
		@show_filter = cookies[:show_filter]

		@ads = Ad.published
			.filter(params.slice(:crop_type_id))
			.filter(params.slice(:volume_min))
			.filter(params.slice(:volume_max))
			.filter(params.slice(:price_min))
			.filter(params.slice(:price_max))
			.filter(params.slice(:region_id))
			.order("published_at desc")


		if @ad_type == "buy"
			@ads = @ads.buy
		else
			@ads = @ads.sell
		end
	end

	def ad_params
		params.require(:ad).permit(:user, :crop_type_id, :other_crop_type, :description, :price, :volume, :volume_unit, :village, :region_id, :position, :status, :lat, :lng, :final_price, :archived_at, :buyer_id, :buyer_price, :rating, :ad_type)
	end
	def user_params
		params.require(:user).permit(:name, :email, :phone_number)
	end
end
