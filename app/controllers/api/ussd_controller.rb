class Api::UssdController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_action :find_user_by_phone, :restrict_access

  respond_to :json

  def post_ad
    #a little more information needed, we need to figure out location stuff

    @ad = Ad.new(params.permit(:price, :volume, :volume_unit, :crop_type_id, :region_id, :village, :lat, :lng))
    @ad.user = @user
    @ad.ad_type, @ad.status = 0, 1
    if @ad.save!
      render json: {:status => 201}
    else
      render json: {:status => 400}
    end
  end

  def archive_ad
    @ad = Ad.find_by_id(params[:id])

    if @ad.nil?
      respond_with status: 404
    elsif @user.ads.include?(@ad)
      if @ad.update!(:status => 2, :archived_at => Time.now, :final_price => @ad.price)
        respond_with status: 202
      else
        respond_with status: 400
      end
    else
      respond_with status: 401
    end
  end

  #calls db query, returns hash with keys named after db cols
  #modify keys arr based on what we need/want
  def get_ads_for_user
    if @user.nil?
      respond_with status: 404
    else
      user_ads = pluck_to_json(@user.ads.where(:status => 0..1), [:id, :created_at, :crop_type_id, :price, :volume, :region_id, :village])
      respond_with(user_ads, status: 200)
    end
  end

  def get_units
    @units = ["kg", "Bucket", "Sack"].to_json
    respond_with(@units, status: 200)
  end

  def get_crop_types
    @crop_types = pluck_to_json(CropType.all, [:id, :name, :name_sw])
    respond_with(@crop_types, status: 200)
  end

  def get_regions
    @regions = pluck_to_json(Region.all, [:id, :name])
    respond_with(@regions, status: 200)
  end

  #takes AR collection and array of db cols, returns json object with K/Vs
  def pluck_to_json(relation, key_array)
    relation.pluck(*key_array)
            .map{ |pa| Hash[key_array.zip(pa)] }
            .to_json
  end

  def find_user_by_phone
    #might want to use find_by! here since it returns RecordNotFound error
    @user ||= User.find_by(:phone_number => params[:phone])
  end

  #requires token to be sent in header
  #> curl ninayo.com/en/api/etc -H 'Access: Token token=cfd5f147ef3140d8ce2a3e207b129aac'
  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      ApiKey.exists?(access_token: token)
    end
  end

end