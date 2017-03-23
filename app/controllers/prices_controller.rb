# Controller for pricing pages
class PricesController < ApplicationController
  before_action :authenticate_user!

  def new
    @new_prices = []
    5.times do
      @prices << Price.new
    end
    @crop_types = CropType.all.order(:sort_order)
    render :new
  end

  def create
    if params.key?('price')
      Price.create(price_params(params['price']))
    else
      params['prices'].each do |price|
        unless price['price'].blank? || price['region_id'].blank? || price['crop_type_id'].blank?
          Price.create(price_params(price))
        end
      end
    end

    redirect_to prices_path
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
    @prices = Price.includes(:crop_type)
                   .order('created_at desc')
                   .select { |p| p.region_id == 2 }

    @new_prices = []
    5.times do
      @prices << Price.new
    end

    @maize_prices    = @prices.select { |p| p.crop_type_id == 1 }
    @potato_prices   = @prices.select { |p| p.crop_type_id == 2 }
    @avocado_prices  = @prices.select { |p| p.crop_type_id == 6 }
    @onion_prices    = @prices.select { |p| p.crop_type_id == 13 }
    @tomato_prices   = @prices.select { |p| p.crop_type_id == 8 }

    @view = 'dar'
    @price = Price.new(:region_id => 2)
  end

  def iringa
    @prices = Price.includes(:crop_type)
                   .order('created_at desc')
                   .select { |p| p.region_id == 5 }

    @new_prices = []
    5.times do
      @prices << Price.new
    end

    @maize_prices    = @prices.select { |p| p.crop_type_id == 1 }
    @potato_prices   = @prices.select { |p| p.crop_type_id == 2 }
    @avocado_prices  = @prices.select { |p| p.crop_type_id == 6 }
    @onion_prices    = @prices.select { |p| p.crop_type_id == 13 }
    @tomato_prices   = @prices.select { |p| p.crop_type_id == 8 }

    @view = 'iringa'
    @price = Price.new(:region_id => 5)
  end

  def mbeya
    @prices = Price.includes(:crop_type)
                   .order('created_at desc')
                   .select { |p| p.region_id == 13 }

    @new_prices = []
    5.times do
      @prices << Price.new
    end

    @maize_prices    = @prices.select { |p| p.crop_type_id == 1 }
    @potato_prices   = @prices.select { |p| p.crop_type_id == 2 }
    @avocado_prices  = @prices.select { |p| p.crop_type_id == 6 }
    @onion_prices    = @prices.select { |p| p.crop_type_id == 13 }
    @tomato_prices   = @prices.select { |p| p.crop_type_id == 8 }

    @view = 'mbeya'
    @price = Price.new(:region_id => 13)
  end

  private

  def price_params(params_hash)
    params_hash.permit(:region_id, :crop_type_id, :price)
  end
end
