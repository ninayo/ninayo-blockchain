class Bot::BotController < ApplicationController
 
  include Trackable

  skip_before_filter :verify_authenticity_token

  before_action :find_user_by_bot_id, only: [:post_ad]

  def find_user_by_bot_id
    @user = User.find_by(:fb_bot_id => params[:fb_bot_id])
    link_facebook unless @user && @user.id
  end

  def link_facebook
    phone     = params[:phone_number].gsub("+", "").split("/")[0]
    fb_bot_id = params[:fb_bot_id]
    user_name = [params[:fname], params[:lname]].join(" ").strip

    return bad_phone unless valid_phone?(phone)

    @user = User.find_by_phone_number(phone) || User.find_by(:fb_bot_id => fb_bot_id)

    if @user && @user.id #found preregistered user
      if @user.update(:fb_bot_id => fb_bot_id, :name => user_name, :phone => phone)
        #generic_message("DEBUG: Account found, updated with fb_bot_id")
      else
        generic_message("DEBUG: Couldn't update user #{@user.id}, failed with #{@user.errors.full_messages}")
      end
    else
      @user = User.create(:name => user_name, 
                          :phone_number => phone, 
                          :password => SecureRandom.urlsafe_base64(16), 
                          :fb_bot_id => fb_bot_id, 
                          :agreement => true)
      
      if @user.persisted?
        #render json: [{"text": "Didn't find user, created one. ID is #{@user.id}"}]
      else
        render json: [{"text": "DEBUG: Couldn't persist user"}]
      end

    end

  end

  def post_ad

    link_facebook unless @user && @user.id

    region    = Region.find_by_name(params[:region_name].titleize)
    district  = District.find_by_name(params[:district_name].titleize)
    ward      = Ward.find_by_name(params[:ward_name].titleize)
    crop_type = CropType.find_by(:name_sw => params[:crop_name].titleize)

    @ad = Ad.new(:region_id => region.id, :district_id => district.id)
    
    parse_price(params[:crop_price])
    parse_volume(params[:crop_volume])

    if ward && ward.id
      @ad.ward_id = ward.id
    end

    @ad.village = params[:village].titleize

    if crop_type && crop_type.id
      @ad.crop_type_id = crop_type.id
    else
      @ad.crop_type_id = 10 #other
      @ad.other_crop_type = params[:crop_name].titleize
    end

    @ad.user_id = @user.id
    @ad.status = 1

    if @ad.save
      ad_success
    else
      fail_message(@ad.errors.full_messages)
    end
  end

  def parse_price(price)
    @ad.price = price.split("/=")[0].gsub!(/[^0-9]/,'')
  end

  def parse_volume(volume)
    @ad.volume_unit = volume.split(" ")[0]
    @ad.volume = volume.split(" ")[1].gsub!(/[^0-9]/,'')
  end

  def bad_phone
    generic_message("Invalid phone number, please try again.")
  end

  def ad_success
    render json: [
      {
        "attachment": {
          "type": "template",
          "payload": {
            "template_type": "button",
            "text": "Bonyeza hapa www.NINAYO.com kuona tangazo lako au tembelea tovuti kuona bei za mazao mengine kebekebe nchini.",
            "buttons": [
              {
                "type": "web_url",
                "url": "#{ad_url(@ad.id)}",
                "title": "NINAYO"
                }
              ]
            }
          }
        }
      ]
  end

  def fail_message(messages)
    render json: [
        {"text": "Sorry, something went wrong. Please try again later. #{messages}"}
      ]
  end

  def auth_link #why arent you werking
    render json: [
      {
        "attachment": {
          "type": "template",
          "payload": {
            "template_type": "button",
            "text": "Karibu NINAYO",
            "buttons": [
              {
                "type": "account_link",
                "url": "https://www.ninayo.com/users/auth/facebook?locale=sw"
                }
              ]
            }
          }
        }
      ]
  end

  def generic_message(message)
    return false unless message.is_a?(String)
    render json: [
      {"text": message}
    ]
  end

  def valid_phone?(number)
    (number.length == 9) || (number.length == 10)
  end

end