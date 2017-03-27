# Controller for pricing pages
class PricesController < ApplicationController
  before_action :authenticate_user!

  def new
    new_prices
    render :new
  end

  def create
    
    @region_id = nil

    if params.key?('price')
      Price.create(price_params(params['price']))
      @region_id = price_params(params['price']).region_id
    else
      params['prices'].each do |price|
        unless price['price'].blank? || price['region_id'].blank? || price['crop_type_id'].blank?
          Price.create(price_params(price))
          @region_id = price_params(price).region_id
        end
      end
    end

    if @region_id == 2
      redirect_to dar_price_path, message: "Dar prices uploaded"
    elsif @region_id == 5
      redirect_to iringa_price_path, message: "Iringa prices uploaded"
    elsif @region_id == 13
      redirect_to mbeya_price_path, message: "Mbeya prices uploaded"
    else
      redirect_to prices_path, error: "Something went wrong."
    end
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


  private

  def new_prices
    @new_prices = []
    5.times { @new_prices << Price.new }
    @crop_types = CropType.all.order(:sort_order)
  end

  def get_prices(region_id)
    @prices = Price.includes(:crop_type)
                   .order('created_at desc')
                   .select { |p| p.region_id == region_id }

    @maize_prices    = @prices.select { |p| p.crop_type_id == 1 }
    @potato_prices   = @prices.select { |p| p.crop_type_id == 2 }
    @avocado_prices  = @prices.select { |p| p.crop_type_id == 6 }
    @onion_prices    = @prices.select { |p| p.crop_type_id == 13 }
    @tomato_prices   = @prices.select { |p| p.crop_type_id == 8 }
  end

  def price_params(params_hash)
    params_hash.permit(:region_id, :crop_type_id, :price)
  end
end
