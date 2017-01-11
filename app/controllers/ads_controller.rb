class AdsController < ApplicationController
  include Trackable

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
    ab_finished("frontpage")
    @ads = @ads.includes(:crop_type)
               .includes(:user)
               .includes(:region)
               .includes(:district)
               .includes(:ward)
               .page(params[:page])

    @crop_types = CropType.all.order(:sort_order)
    @regions = Region.all.order(:name)
    @districts = District.all.order(:name)
    @wards = Ward.all.order(:name)

    respond_to do |format|
      format.html { render layout: 'startpage' } # index.html.erb
      format.js { render json: @ads }
      format.json { render json: @ads }
    end
  end

  def map
    @ads = @ads.includes(:crop_type) # determines map markers, use .where
    @crop_types = CropType.all.order(:sort_order)
    @regions = Region.all.order(:name)
  end

  def show # not sure what's going on in this method, won't break it yet
    @back_url = session[:previous_url]
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
        # TODO: break out into method
        # note: Potential performance issue
        ad_log = AdLog.new
        ad_log.ad = @ad
        ad_log.user = current_user || nil
        # TODO: Find a better way to assign event_type (use enum instead?)
        ad_log.event_type = EventType.first
        ad_log.save!
      end
      #respond_with(@ad)
    end
  end

  def infopanel
    render '_infopanel', layout: false
  end

  def contact_info
    # TODO: break out into method
    # note: Potential performance issue
    ad_log = AdLog.new
    ad_log.ad = @ad
    ad_log.user = current_user || nil
    # TODO: Find a better way to assign event_type (use enum instead?)
    ad_log.event_type = EventType.last
    ad_log.save!

    @show_contact_info = true

    respond_to do |format|
      format.html { render 'show' }
      format.js
    end
  end

  def call_contact
    call_log              = CallLog.new
    call_log.ad_id        = @ad.id
    call_log.caller_id    = current_user.id
    call_log.receiver_id  = @ad.user.id
    call_log.save

    ab_finished("ad show page")

    redirect_to "tel:#{@ad.user.phone_number}"
  end

  def text_contact
    text_log = TextLog.new
    text_log.ad_id = @ad.id
    text_log.sender_id = current_user.id
    text_log.receiver_id = @ad.user.id
    text_log.save

    ab_finished("ad show page")

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
    not_found if current_user.id != @ad.user.id
    @show_contact_info = true
    @preview = true
  end

  def new
    ab_finished("frontpage")
    @ad = Ad.new
    @ad.user = current_user
    @crop_types = CropType.all.order(:sort_order)
    respond_with(@ad)
  end

  def edit
    not_found if @ad.archived?
    @crop_types = CropType.all.order(:sort_order)
  end

  def create
    if current_user && !current_user.id.nil?
      current_user.update(user_params) unless user_params[:name].blank? || user_params[:phone_number].blank?
    end

    @ad               = Ad.new(ad_params)
    @ad.user          = current_user || User.where(:phone_number => params[:ad][:user][:phone_number], :encrypted_password => params[:ad][:user][:password]).first_or_create do |user|
      user.name       = params[:ad][:user][:name]
      user.email      = "no_email#{rand(999999)}@ninayo.com"
      user.whatsapp_id = params[:ad][:user][:whatsapp_id]
      user.gender     = params[:ad][:user][:gender]
      user.birthday   = params[:ad][:user][:birthday].to_s
      user.region_id  = ad_params[:region_id]
      user.district_id = ad_params[:district_id]
      user.ward_id    = ad_params[:ward_id]
      user.village    =  ad_params[:village]
      user.password   = params[:ad][:user][:password]
      user.password_confirmation = params[:ad][:user][:password_confirmation]
      user.agreement = true
      if user.save
        user.update(email: nil)
        sign_in user
      else
        # do something
      end
    end

    @ad.crop_type_id  = ad_params[:crop_type_id]
    @ad.lat           = @ad.user.district.lat unless @ad.user.district.nil?
    @ad.lng           = @ad.user.district.lon unless @ad.user.district.nil?
    @ad.status        = 1 # set to active automatically, skip preview

    @ad.user.district_id  = @ad.district_id if @ad.user.district_id.nil?
    @ad.user.ward_id      = @ad.ward_id if @ad.user.ward_id.nil?
    @ad.user.village = @ad.village if @ad.user.village.nil?

    @ad.region_id = @ad.user.region_id
    @ad.district_id = @ad.user.district_id
    @ad.ward_id = @ad.user.ward_id
    @ad.village = @ad.user.village

    if @ad.save
      # if @ad.save
      #   # redirect_to :action => "preview", :id => @ad.id
      # else
      #   @crop_types = CropType.all.order(:sort_order)
      #   @ad.user = current_user
      #   render "new"
      # end

      # if @ad.user.seller_rating <= 4.0
      #   @ad.user.seller_rating += 1.0
      #   @ad.user.save
      # end
      track_new
      redirect_to ad_url(@ad.id), notice: 'Hongera! Tangazo lako lipo mtandaoni. Sasa, unaweza kuweka tangazo lingine au kuona bei za bidhaa zinazouzwa maeneo ya jirani.'
    else
      track_failure
      @ad.user = current_user
      @crop_types = CropType.all.order(:sort_order)
      render 'new'
    end
  end

  def update
    @ad.update(ad_params)
    @ad.user.update(user_params)

    if @ad.save(context: :save_ad)
      if @ad.published?
        # if no user location info, update with the ad
        update_user_location
        redirect_to ad_path(@ad)
      else
        redirect_to mypage_archive_path, notice: 'Tangazo umekuwa jalada!'
      end
    else
      @crop_types = CropType.all.order(:sort_order)
      render 'edit'
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
    if type == 'favorite'
      current_user.favorites << @ad
      redirect_to :back, notice: "You added #{@ad.title} to your favorites"

    elsif type == 'unfavorite'
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
        redirect_to root_path, notice: 'This ad is already archived'
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
      @rating = Rating.new(rater_id: current_user.id,
                           ad: @ad,
                           score: params[:score],
                           role: 'seller',
                           user_id: @ad.user_id)
      @rating.save ? (redirect_to root_path, notice: 'Thanks for rating the seller!') : (render 'rate_seller')
    else
      render 'rate_seller'
    end
  end

  private

  def ga_info
    {
      ad_id: @ad.id,
      type: @ad.ad_type,
      unit_type: @ad.volume_unit,
      crop_type: @ad.crop_type_id,
      region: @ad.region_id,
      village: @ad.village,
      gclid: params[:gclid],
      cid: google_analytics_client_id
    }
  end

  def crop_name(id)
    CropType.find_by_id(id).name_sw
  end

  def track_new
    # track_event(category, type, action, label)
    track_event('Engagement & Acquisition',
                'Post Advert',
                "new #{@ad.ad_type} ad: #{@ad.region.name}",
                "NEW #{@ad.ad_type.upcase} AD: #{ga_info}")
  end

  def track_update
    track_event('Engagement & Acquisition',
                'Advert Update',
                "update #{@ad.ad_type} ad: #{@ad.region.name}",
                "UPDATE #{@ad.ad_type.upcase} AD: #{ga_info}")
  end

  def track_archive
    track_event('Engagement & Acquisition',
                'Advert Archive',
                "archive #{@ad.ad_type} ad: #{@ad.region.name}",
                "ARCHIVE #{@ad.ad_type.upcase} AD: #{ga_info}")
  end

  def track_contact_reveal
    track_event('Engagement & Acquisition',
                'Phone Reveal',
                "reveal contact details on #{@ad.ad_type} ad: #{@ad.region.name}",
                "REVEAL #{@ad.ad_type.upcase} AD CONTACT: #{ga_info}")
  end

  def track_call
    track_event('Engagement & Acquisition',
                'Phone Call',
                "call made on #{@ad.ad_type} ad: #{@ad.region.name}",
                "CALL #{@ad.ad_type.upcase} AD PHONE")
  end

  def track_text
    track_event('Engagement & Acquisition',
                'Text message',
                "text sent on #{@ad.ad_type} ad: #{@ad.region.name}",
                "TEXT #{@ad.ad_type.upcase} AD PHONE")
  end

  def track_whatsapp
    track_event('Engagement & Acquisition',
                'Whatsapp message',
                "whatsapp sent on #{@ad.ad_type} ad: #{@ad.region.name}",
                "WHATSAPP #{@ad.ad_type.upcase} AD CONTACT")
  end

  def track_favorite
    track_event('Engagement & Acquisition',
                'Advert Added to Favorite',
                "favorite #{@ad.ad_type} ad: #{@ad.region.name}",
                "FAVORITE #{@ad.ad_type.upcase} AD: #{ga_info}")
  end

  def track_failure
    track_event('Engagement & Acquisition',
                'Failed Post Advert Error',
                'failed to post ad',
                "FAILED AD: #{ga_info}")
  end

  def update_user_location # assign location if we don't have one
    @ad.user.region_id = @ad.region_id if !@ad.user.region_id && @ad.region_id
    @ad.user.district_id = @ad.district_id if !@ad.user.district_id && @ad.district_id
    @ad.user_ward_id = @ad.ward_id if !@ad.user.ward_id && @ad.ward_id
    @ad.user.village = @ad.village if !@ad.user.village && @ad.village
    @ad.user.save
  end

  def buyers(ad)
    buyers = []

    CallLog.where(ad_id: ad.id).each { |a| buyers.push(a.caller) unless buyers.include?(a.caller) }
    TextLog.where(ad_id: ad.id).each { |a| buyers.push(a.sender) unless buyers.include?(a.sender) }
    WhatsappLog.where(ad_id: ad.id).each { |a| buyers.push(a.sender) unless buyers.include?(a.sender) }

    buyers = buyers.sort! { |a, b| a.name.downcase <=> b.name.downcase }
  end

  def set_ad
    @ad = Ad.find(params[:id])
  end

  def get_ads
    @ad_type = params[:ad_type] || 'sell'
    @crop_type_id = params[:crop_type_id]
    @volume_min = params[:volume_min]
    @volume_max = params[:volume_max]
    @price_min = params[:price_min]
    @price_max = params[:price_max]
    @region_id = params[:region_id]
    @district_id = params[:district_id]
    @ward_id = params[:ward_id]
    @show_filter = cookies[:show_filter]

    @ads = Ad.published
             .where(:created_at => (Date.today - 30)..(Date.today))
             .filter(params.slice(:crop_type_id))
             .filter(params.slice(:volume_min))
             .filter(params.slice(:volume_max))
             .filter(params.slice(:price_min))
             .filter(params.slice(:price_max))
             .filter(params.slice(:region_id))
             .order('published_at desc')

    if @ad_type == 'buy'
      @ads = @ads.buy
    else
      @ads = @ads.sell
    end
  end

  def ad_params
    params.require(:ad).permit(:user,
                               :crop_type_id,
                               :other_crop_type,
                               :description,
                               :price,
                               :volume,
                               :volume_unit,
                               :village,
                               :region_id,
                               :district_id,
                               :ward_id,
                               :position,
                               :status,
                               :negotiable,
                               :lat,
                               :lng,
                               :final_price,
                               :archived_at,
                               :buyer_id,
                               :buyer_price,
                               :rating,
                               :ad_type,
                               :transport_type)
  end

  def user_params
    params.require(:user).permit(:name,
                                 :email,
                                 :gender,
                                 :phone_number,
                                 :whatsapp_id,
                                 :region_id,
                                 :district_id,
                                 :ward_id,
                                 :village,
                                 :birthday)
  end
end
