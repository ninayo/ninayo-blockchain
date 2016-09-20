class Bot::BotController < ApplicationController

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

  def auth
    @user = User.find_by(:fb_bot_id => params[:uid])
    if @user && @user.id
      render json: [
        {"text": "I recognize you. #{@user.name}!"}
      ]
    else
      render json: [
        {
          "attachment": {
            "type": "template",
            "payload": {
              "template_type": "button",
              "text": "I don't recognize you. Please link your Facebook!",
              "buttons": [
                {
                  "type": "web_url",
                  "url": "https://www.ninayo.com/users/auth/facebook?locale=sw",
                  "title": "Link Facebook"
                }
              ]
            }
          }
        }
      ]
    end
  end

  def ad_params
    params.permit(:price, :crop_type_id, :volume, :volume_unit, :region_id, :district_id, :ward_id, :village, :ad_type)
  end

  def user_params
    params.permit(:phone_number, :uuid, :region_id, :district_id, :ward_id, :village)
  end

end