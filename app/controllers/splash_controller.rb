class SplashController < ApplicationController

  # page for letsencrypt verification
  def letsencrypt_verify
    respond_with 'b6LjPkmXSE43hN2MmKoNCWEY9dIIw_xWvAjOH-2vtMU.f7vLMOThcyEXB9qAI5BSN_yaTVOEKeyNNW23TFYNCRA'
  end

  def index
    @featured_ad = Ad.last(5).sample
  end

  def instructions
    ab_finished("what-is-ninayo")
  end

  def get_started
  	redirect_to root_url if current_user && current_user.id
  end

  def congrats
  	redirect_to root_url unless current_user && current_user.admin?
  end

end