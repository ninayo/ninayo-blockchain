class MypageController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def favorites
    # TODO: filter out ads the user marked as bought
    @ads = current_user.favorites
                       .published
                       .where('buyer_id IS null OR buyer_id != ?', current_user.id)
                       .includes(:user)
                       .includes(:crop_type)
                       .page(params[:page])

    @bought_ads = Ad.where(buyer: current_user, buyer_price: nil)
                    .page(params[:page])

    @view = 'favorites'

    respond_to do |format|
      format.html
    end
  end

  def current
    @ads = current_user.ads
                       .published
                       .includes(:crop_type)
                       .page(params[:page])
    @view = 'current'

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def archive
    @ads = current_user.ads
                       .archived
                       .includes(:user, :buyer, :crop_type)
                       .page(params[:page])

    @bought_ads = Ad.where(buyer: current_user)
                    .where.not(archived_at: nil)
                    .includes(:user)
                    .page(params[:page])

    @view = 'archived'

    respond_to do |format|
      format.html
    end
  end
end
