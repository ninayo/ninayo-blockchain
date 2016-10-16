class AdsController < ApplicationController

	include Trackable

	after_action :track_new, only: [:create]
	after_action :track_update, only: [:update]
	after_action :track_archive, only: [:archive]

	after_action :track_contact_reveal, only: [:contact_info]
	after_action :track_favorite, only: [:favorite]
	after_action :track_call, only: [:call_contact]
	after_action :track_text, only: [:text_contact]
	after_action :track_whatsapp, only: [:whatsapp_contact]

	before_action :set_ad, only: [:show, :infopanel, :contact_info, :call_contact, :text_contact, :whatsapp_contact, :edit, :preview, :archive, :update, :delete, :rate_seller, :save_buy_info]
	before_action :get_ads, only: [:index, :map]
	before_action :authenticate_user!, :except => [:new, :create, :index, :map, :show, :infopanel]

	respond_to :html, :json

	def index
		@ads = @ads.includes(:crop_type)
					.includes(:user)
					.includes(:region)
					.includes(:district)
					.includes(:ward)
					.page(params[:page])

		@crop_types = CropType.all.order(:sort_order)
		@regions = Region.all.order(:name)

		respond_to do |format|
			format.html { render layout: 'startpage' } # index.html.erb
			format.js { render json: @ads }
			format.json { render json: @ads }
		end
	end

	def map
		@ads = @ads.includes(:crop_type) #this determines number of map markers to draw, can use .where
		@crop_types = CropType.all.order(:sort_order)
		@regions = Region.all.order(:name)
	end

	def show #i'm not sure what's going on in this method, but it works so i won't break it yet
		if !@ad
			not_found
		elsif @ad.archived? || @ad.deleted?
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

	def call_contact
		call_log 							= CallLog.new
		call_log.ad_id 				= @ad.id
		call_log.caller_id 		= current_user.id
		call_log.receiver_id 	= @ad.user.id
		call_log.save

		redirect_to "tel:#{@ad.user.phone_number}"
	end

	def text_contact
		text_log = TextLog.new
		text_log.ad_id = @ad.id
		text_log.sender_id = current_user.id
		text_log.receiver_id = @ad.user.id
		text_log.save

		redirect_to "sms:#{@ad.user.phone_number}"
	end

	def whatsapp_contact
		whatsapp_log = WhatsappLog.new
		whatsapp_log.ad_id = @ad.id
		whatsapp_log.sender_id = current_user.id
		whatsapp_log.receiver_id = @ad.user.id
		whatsapp_log.save

		redirect_to "intent://send/#{@ad.user.whatsapp_id}#Intent;scheme=smsto;package=com.whatsapp;action=android.intent.action.SENDTO;end"
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
		@crop_types = CropType.all.order(:sort_order)
		respond_with(@ad)
	end

	def edit
		if @ad.archived?
			not_found
		end
		@crop_types = CropType.all.order(:sort_order)
	end

	def create
		# if current_user.info_needed?
		# 	current_user.update(user_params)
		# end
		if current_user
			if current_user.location_needed?

				if current_user.region_id.nil?
					current_user.update(:region_id => ad_params[:region_id])
				end

				if current_user.district_id.nil?
					current_user.update(:district_id => ad_params[:district_id])
				end

				if current_user.ward_id.nil?
					current_user.update(:ward_id => ad_params[:ward_id])
				end

				if current_user.village.blank?
					current_user.update(:village => ad_params[:village])
				end

			end

			if current_user.info_needed?
				if current_user.phone_number.nil? || current_user.phone_number.blank?
					current_user.update(:phone_number => user_params[:phone_number])
				end

				if current_user.name.nil? || current_user.name.blank?
					current_user.update(:name => user_params[:name])
				end
			end
		end

		@ad 							= Ad.new(ad_params)
		@ad.user 					= current_user || User.where(:phone_number => params[:ad][:user][:phone_number], :encrypted_password => params[:ad][:user][:password]).first_or_create do |user|
			user.name 			= params[:ad][:user][:name]
			user.email 			= "no_email#{rand(999999)}@ninayo.com"
			user.whatsapp_id = params[:ad][:user][:whatsapp_id]
			user.gender 		= params[:ad][:user][:gender]
			user.region_id 	= ad_params[:region_id]
			user.district_id = ad_params[:district_id]
			user.ward_id 		= ad_params[:ward_id]
			user.village 		=  ad_params[:village]
			user.password 	= params[:ad][:user][:password]
			user.password_confirmation = params[:ad][:user][:password_confirmation]
			user.agreement = true
			if user.save
				user.update(:email => nil)
				sign_in user
			else
				#do something
			end
		end
		#@ad.user.update(user_params)
		@ad.crop_type_id 	= ad_params[:crop_type_id]
		#@ad.ad_type 			= 0 #i want to sell assumes you're going to sell
		@ad.lat 					= @ad.user.district.lat
		@ad.lng 					= @ad.user.district.lon
		@ad.status 				= 1 #set to active automatically, skip preview

		@ad.user.district_id 	= @ad.district_id if @ad.user.district_id.nil?
		@ad.user.ward_id 			= @ad.ward_id if @ad.user.ward_id.nil?
		@ad.user.village = @ad.village if @ad.user.village.nil?

		@ad.region_id = @ad.user.region_id
		@ad.district_id = @ad.user.district_id
		@ad.ward_id = @ad.user.ward_id
		@ad.village = @ad.user.village

		if @ad.save
			# if @ad.save
			# 	# redirect_to :action => "preview", :id => @ad.id
			# else
			# 	@crop_types = CropType.all.order(:sort_order)
			# 	@ad.user = current_user
			# 	render "new"
			# end

			# if @ad.user.seller_rating <= 4.0
			# 	@ad.user.seller_rating += 1.0
			# 	@ad.user.save
			# end

			redirect_to ad_url(@ad.id), notice: "Hongera! Tangazo lako lipo mtandaoni. Sasa, unaweza kuweka tangazo lingine au kuona bei za bidhaa zinazouzwa maeneo ya jirani."
		else
			track_failure
			@ad.user = current_user
			@crop_types = CropType.all.order(:sort_order)
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
						redirect_to mypage_archive_path, notice: "Your ad has been archived!"
					else
						@buyers = buyers(@ad)
						render "archive"
					end
				else
					redirect_to mypage_archive_path, notice: "Your ad has been archived!"
				end
			else
				redirect_to :action => "preview", :id => @ad.id
			end
		else

			if @ad.archived?
				@buyers = buyers(@ad)
				render "archive"
			else
				@crop_types = CropType.all.order(:sort_order)
				render "edit"
			end
		end

	end

	def delete
		if current_user && current_user.admin?
			@ad.deleted!
			redirect_to root_path
		else
			not_found
		end
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

	def ga_info
		# "ga_info"

		{
			ad_id: @ad.id,
			type: @ad.ad_type,
			unit_type: @ad.volume_unit,
			crop_type: @ad.crop_type_id,
			region: @ad.region_id,
			village: @ad.village,
			amount: @ad.price,
			utm_source: params[:utm_source],
			utm_medium: params[:utm_medium],
			utm_campaign: params[:utm_campaign],
			gclid: params[:gclid],
			cid: google_analytics_client_id
		}
	end

	def crop_name(id)
		CropType.find_by_id(id).name_sw
	end
	#track_event(category, type, action, label)
	def track_new
		track_event('Engagement & Acquisition', 'Post Advert', "new #{@ad.ad_type} advert added: #{crop_name(@ad.crop_type_id)}", "NEW #{@ad.ad_type.upcase} AD: #{ga_info}")
	end

	def track_update
		track_event('Engagement & Acquisition', 'Advert Update', "update #{@ad.ad_type} advert added: #{crop_name(@ad.crop_type_id)}", "UPDATE #{@ad.ad_type.upcase} AD: #{ga_info}")
	end

	def track_archive
		track_event('Engagement & Acquisition', 'Advert Archive', "archive #{@ad.ad_type} advert added: #{crop_name(@ad.crop_type_id)}", "ARCHIVE #{@ad.ad_type.upcase} AD: #{ga_info}")
	end

	def track_contact_reveal
		track_event('Engagement & Acquisition', 'Phone Reveal', "reveal contact details on #{@ad.ad_type} advert: #{crop_name(@ad.crop_type_id)}", "REVEAL #{@ad.ad_type.upcase} AD CONTACT: #{ga_info}")
	end

	def track_call
		track_event('Engagement & Acquisition', 'Phone Call', "call made on #{@ad.ad_type} advert: #{crop_name(@ad.crop_type_id)}", "CALL #{@ad.ad_type.upcase} AD PHONE")
	end

	def track_text
		track_event('Engagement & Acquisition', 'Text message', "text sent on #{@ad.ad_type} advert: #{crop_name(@ad.crop_type_id)}", "TEXT #{@ad.ad_type.upcase} AD PHONE")
	end

	def track_whatsapp
		track_event('Engagement & Acquisition', 'Whatsapp message', "whatsapp sent on #{@ad.ad_type} advert: #{crop_name(@ad.crop_type_id)}", "WHATSAPP #{@ad.ad_type.upcase} AD CONTACT")
	end

	def track_favorite
		track_event('Engagement & Acquisition', 'Advert Added to Favorite', "favorite #{@ad.ad_type} advert: #{crop_name(@ad.crop_type_id)}", "FAVORITE #{@ad.ad_type.upcase} AD: #{ga_info}")
	end

	def track_failure
		track_event('Engagement & Acquisition', 'Failed Post Advert Error', "failed to post advert", "FAILED AD: #{ga_info}")
	end

	def update_user_location #if we don't have a location for a user, assign one once they post an ad with a location
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
		params.require(:ad).permit(:user, :crop_type_id, :other_crop_type, :description, :price, :volume, :volume_unit, :village, :region_id, :district_id, :ward_id, :position, :status, :lat, :lng, :final_price, :archived_at, :buyer_id, :buyer_price, :rating, :ad_type)
	end
	def user_params
		params.require(:user).permit(:name, :email, :phone_number, :region_id, :district_id, :ward_id, :village)
	end
end
