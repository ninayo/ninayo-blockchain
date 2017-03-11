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
    @prices = Price.all

    @view = 'dar'

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def iringa
    @prices = Price.where('region_id IS 5')
                    .includes(:crop_type)
                    .page(params[:page])

    @view = 'iringa'

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def mbeya
    @prices = Price.where('region_id IS 13')
                    .includes(:crop_type)
                    .page(params[:page])

    @view = 'mbeya'

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
