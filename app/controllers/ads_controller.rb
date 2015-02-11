class AdsController < ApplicationController
  before_action :set_ad, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @ads = Ad.all
    respond_with(@ads)
  end

  def show
    respond_with(@ad)
  end

  def new
    @ad = Ad.new
    respond_with(@ad)
  end

  def edit
  end

  def create
    @ad = Ad.new(ad_params)
    @ad.save
    respond_with(@ad)
  end

  def update
    @ad.update(ad_params)
    respond_with(@ad)
  end

  def destroy
    @ad.destroy
    respond_with(@ad)
  end

  private
    def set_ad
      @ad = Ad.find(params[:id])
    end

    def ad_params
      params.require(:ad).permit(:title, :description, :price)
    end
end
