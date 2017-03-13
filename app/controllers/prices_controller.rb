# Controller for pricing pages
class PricesController < ApplicationController
  before_action :authenticate_user!

  def index
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

    @maize_prices    = @prices.select { |p| p.crop_type_id = 1}
    @potato_prices   = @prices.select { |p| p.crop_type_id = 2}
    @avocado_prices  = @prices.select { |p| p.crop_type_id = 6}
    @onion_prices    = @prices.select { |p| p.crop_type_id = 13}
    @tomato_prices   = @prices.select { |p| p.crop_type_id = 8}

    @view = 'dar'

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def iringa
    @prices = Price.includes(:crop_type)
                    .order('created_at desc')
                    .select { |p| p.region_id == 5 }

    @maize_prices    = @prices.select { |p| p.crop_type_id == 1 }
    @potato_prices   = @prices.select { |p| p.crop_type_id == 2 }
    @avocado_prices  = @prices.select { |p| p.crop_type_id == 6 }
    @onion_prices    = @prices.select { |p| p.crop_type_id == 13 }
    @tomato_prices   = @prices.select { |p| p.crop_type_id == 8 }

    @view = 'iringa'

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def mbeya
    @prices = Price.includes(:crop_type)
                    .order('created_at desc')
                    .select { |p| p.region_id == 13 }

    @maize_prices    = @prices.select { |p| p.crop_type_id == 1 }
    @potato_prices   = @prices.select { |p| p.crop_type_id == 2 }
    @avocado_prices  = @prices.select { |p| p.crop_type_id == 6 }
    @onion_prices    = @prices.select { |p| p.crop_type_id == 13 }
    @tomato_prices   = @prices.select { |p| p.crop_type_id == 8 }

    @view = 'mbeya'

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
