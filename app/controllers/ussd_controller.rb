class UssdController < ApplicationController

  before_action :find_user_by_phone

  respond_to :json

  def post_ad
  end

  def archive_ad
    @ad = Ad.find_by_id(params[:id])
    if @ad.archived_at.nil?
      @ad.archive
    else
      not_found
    end
  end

  def get_ads_for_user
    #calls db query, returns hash with keys named after db cols
    #modify keys arr based on what we need/want
    user_ads = pluck_to_json(@user.ads.where(:status => 2), [:id, :crop_type_id, :created_at, :village]) #or whatever
    respond_with user_ads
  end

  def get_units
    @units = ["kg", "Bucket", "Sack"].to_json
    respond_with @units
  end

  def get_crop_types
    @crop_types = pluck_to_json(CropType.all, [:id, :name])
    respond_with @crop_types
  end

  def get_regions
    @regions = pluck_to_json(Region.all, [:id, :name])
    respond_with @regions
  end

  def pluck_to_json(relation, key_array)
    #takes AR collection and array of db cols, returns json object with K/Vs
    relation.pluck(*key_array)
            .map{ |pa| Hash[key_array.zip(pa)] }
            .to_json
  end

  def find_user_by_phone
    @user ||= User.find_by(:phone_number => text_params[:phone_number])
  end

  def new_user?
    !!find_user_by_phone
  end

  def text_params
    params.require(:ussd).permit(:msisdn,
                                 :session_id,
                                 :service_code,
                                 :phone_number,
                                 :type,
                                 :message,
                                 :sequence,
                                 :client_state
                                )
  end

  #not needed for now if Tigo is doing the parsing for us?
  # def parse_options(array)
  #   #first 10 chars of first eight options + selection numbers, join into string with cancel option
  #   array.map{ |el| "#{array.index(el) + 1}. #{el[0..9]}" }[0...9]
  #        .join("\n") + "\n 0. Cancel"
  # end

end