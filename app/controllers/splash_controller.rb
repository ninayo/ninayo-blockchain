class SplashController < ApplicationController

  def index
    @featured_ad = Ad.last(5).sample
  end

  def instructions
  end

  def get_started
  end

end