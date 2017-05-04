# Controller for pricing pages
class PricesController < ApplicationController

  before_action :check_role, only: [:new, :create, :new_dar_price, :new_iringa_price, :new_mbeya_price]
  
  def new
    new_prices
    render :new
  end

  def create
    
    @region_id = nil

    if params.key?('price')
      Price.create(price_params(params['price']))
      @region_id = price_params(params['price'])["region_id"]
    else
      params['prices'].each do |price|
        unless price['price'].blank? || price['region_id'].blank? || price['crop_type_id'].blank?
          Price.create(price_params(price))
          @region_id = price_params(price)["region_id"]
        end
      end
    end

    redirect_to session[:previous_url], notice: "Prices uploaded successfully"
  end

  def current
    @prices = Price.all
                   .published
                   .includes(:crop_type)
                   .page(params[:page])
    @view = 'current'

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def dar
    get_prices(2)

    @view = 'dar'
  end

  def iringa
    get_prices(5)

    @view = 'iringa'
  end

  def mbeya
    get_prices(13)

    @view = 'mbeya'
  end

  def new_dar_price
    get_prices(2)
    new_prices

    render :new_dar
  end

  def new_iringa_price
    get_prices(5)
    new_prices

    render :new_iringa
  end

  def new_mbeya_price
    get_prices(13)
    new_prices
    
    render :new_mbeya
  end

  def check_role
    unless admin_user?
      redirect_to root_url, alert: "Permission denied"
    end
  end

  private

  def new_prices
    @new_prices = []
    6.times { @new_prices << Price.new }
    @crop_types = CropType.all.order(:sort_order)
  end

  def get_prices(region_id)
    @prices = Price.includes(:crop_type)
                   .order('created_at desc')
                   .select { |p| p.region_id == region_id }

    @maize_prices = @prices.select { |p| p.crop_type_id == 1 }
    @nut_prices = @prices.select { |p| p.crop_type_id == 19 }
    @wheat_prices = @prices.select { |p| p.crop_type_id == 30 }
    @bean_prices = @prices.select { |p| p.crop_type_id == 5 }
    @soy_prices    = @prices.select { |p| p.crop_type_id == 26 }
    @rice_prices   = @prices.select { |p| p.crop_type_id == 11 }

    @recent_sell_ads = Ad.where("created_at > ?", 4.weeks.ago)
                         .select{ |a| a.region_id == region_id }
                         .select { |a| a.ad_type == "sell" }
                         .select { |a| a.volume_unit == "kg" }

    @ninayo_prices = {}
    @ninayo_prices['Maize'] = extract_price_and_average(@recent_sell_ads.select { |a| a.crop_type_id == 1 })
    @ninayo_prices['Groundnuts'] = extract_price_and_average(@recent_sell_ads.select { |a| a.crop_type_id == 19 })
    @ninayo_prices['Wheat'] = extract_price_and_average(@recent_sell_ads.select { |a| a.crop_type_id == 30 })
    @ninayo_prices['Beans'] = extract_price_and_average(@recent_sell_ads.select { |a| a.crop_type_id == 5 })
    @ninayo_prices['Soy'] = extract_price_and_average(@recent_sell_ads.select { |a| a.crop_type_id == 26 })
    @ninayo_prices['Rice'] = extract_price_and_average(@recent_sell_ads.select { |a| a.crop_type_id == 11 })
  end

  def extract_price_and_average(ads)
    return 0 if ads.empty?
    total = 0
    ads.each { |a| total += a.price }
    total / ads.length
  end

  def price_params(params_hash)
    params_hash.permit(:region_id, :crop_type_id, :price)
  end
end
