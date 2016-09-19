class Bot::BotController < ApplicationController

  before_action :find_user_by_uuid, except: [:create_user]

  def create_user
    render json: {:status => 422} if find_user_by_uuid
    @user = User.new(user_params)
    @user.password = SecureRandom.urlsafe_base64(16)
    if @user.save
      render json: {:status => 201}
    else
      render json: {:status => 422}
    end
  end

  def update_user
    render json: {:status => 422} unless find_user_by_uuid
    @user.update(:phone_number => params[:phone_number])
  end

  def post_ad
    @ad = Ad.new(ad_params)
    @ad.user_id = @user.id
    @ad.status = 1
    if @ad.save!
      render json: {:status => 201}
    else
      render json: {:status => 422}
    end
  end

  def find_user_by_uuid
    @user = User.find_by_uuid(params[:uuid])
  end

  def ad_params
    params.permit(:price, :crop_type_id, :volume, :volume_unit, :region_id, :district_id, :ward_id, :village, :ad_type)
  end

  def user_params
    params.permit(:phone_number, :uuid, :region_id, :district_id, :ward_id, :village)
  end

end