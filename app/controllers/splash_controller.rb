class SplashController < ApplicationController

  respond_to :html

  # page for letsencrypt verification
  def letsencrypt_verify
    render body: 'ZfWSZ-8jDoGc8OenfP8JC79QPITHFU6BH9YPvVabGd8.f7vLMOThcyEXB9qAI5BSN_yaTVOEKeyNNW23TFYNCRA'
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
  	redirect_to root_url unless admin_user?
  end

end