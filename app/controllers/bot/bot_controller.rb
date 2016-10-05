class Bot::BotController < ApplicationController
 
  include Trackable

  skip_before_filter :verify_authenticity_token

  #before_action :find_user_by_bot_id, only: [:post_ad]

  def find_user_by_bot_id
    @user = User.find_by(:fb_bot_id => params[:fb_bot_id])
    link_facebook unless @user && @user.id
  end

  def link_facebook
    phone     = params[:phone_number].gsub("+", "").gsub(" ", "").gsub("0255", "").split("/").map{|x| x[/\d+/]}.first
    fb_bot_id = params[:fb_bot_id]
    user_name = [params[:fname], params[:lname]].join(" ").strip

    return bad_phone unless valid_phone?(phone)

    @user = User.find_by_phone_number(phone) || User.find_by(:fb_bot_id => fb_bot_id)

    if @user && !@user.id.nil? #found preregistered user
      if @user.update(:fb_bot_id => fb_bot_id, :name => user_name, :phone_number => phone)
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

    region    = Region.find_by_name(best_match(params[:region_name], Region.all.map(&:name)).titleize)
    district  = District.find_by_name(best_match(params[:district_name], District.all.map(&:name)).titleize) || region.districts.first
    ward      = Ward.find_by_name(best_match(params[:ward_name], Ward.all.map(&:name)).titleize) || district.wards.first
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
    @ad.ad_type = 0
    @ad.status = 1

    if @ad.save
      render json: ad_success and return
    else
      fail_message(@ad.errors.full_messages)
    end
  end

  def parse_price(price)
    @ad.price = price.gsub(",", "").gsub(".", "").gsub(" ", "").split.map{|x| x[/\d+/]}.first
  end

  def parse_volume(volume)
    @ad.volume_unit = volume.split(" ")[0]
    @ad.volume = volume.split(" ")[1]
  end

  def bad_phone
    generic_message("Invalid phone number, please try again.")
  end

  def ad_success
    [
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

  def string_similarity(str1, str2)
    str1.downcase!
    str2.downcase!

    pairs1 = (0..str1.length - 2).collect{|i| str1[i, 2]}.reject { |pair| pair.include?(" ") }
    pairs2 = (0..str2.length - 2).collect{|i| str2[i, 2]}.reject { |pair| pair.include?(" ") }

    union = pairs1.size + pairs2.size

    intersection = 0

    pairs1.each do |p1|
      0.upto(pairs2.size - 1) do |i|
        if p1 == pairs2[i]
          intersection += 1
          pairs2.slice!(i)
          break
        end
      end
    end

    (2.0 * intersection) / union
  end

  def best_match(user_input, master_strings)
    confidence_hash = {}
    master_strings.each { |candidate| confidence_hash[candidate] = string_similarity(user_input, candidate) }
    confidence_hash.sort_by(&:last).last[0]
  end
  

end