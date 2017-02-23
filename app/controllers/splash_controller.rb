class SplashController < ApplicationController

  def index
    @featured_ad = Ad.last(5).sample
  end

  def instructions
  end

  def get_started
  	redirect_to root_url if current_user && current_user.id
  end

  def congrats
  	redirect_to root_url unless current_user && current_user.admin?
  end

end