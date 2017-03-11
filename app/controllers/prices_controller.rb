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
    @prices = Price.find_by(region_id: 2)

    @view = 'dar'

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def iringa
    @prices = Price.find_by(region_id: 5)
                    .includes(:crop_type)
                    .page(params[:page])

    @view = 'iringa'

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def mbeya
    @prices = Price.find_by(region_id: 13)
                    .includes(:crop_type)
                    .page(params[:page])

    @view = 'mbeya'

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
