module Trackable
  extend ActiveSupport::Concern

  def track_event(category, type, action, label)
    push_to_google_analytics('event', ec: category, ea: action, el: label)
  end

  def track_page_view
    path = Rack::Utils.escape("/#{controller_path}/#{action_name}")
    push_to_google_analytics('pageview', dp: path)
  end

  def google_analytics_client_id
    if cookies["_ga"]
      cookies["_ga"].split(".").last(2).join(".")
    else
      555
    end
  end

  def track_new
    # track_event(category, type, action, label)
    track_event('Engagement & Acquisition',
                'Post Advert',
                "new #{@ad.ad_type} ad: #{@ad.region.name}",
                "NEW #{@ad.ad_type.upcase} AD: #{ga_info}")
  end

  def track_update
    track_event('Engagement & Acquisition',
                'Advert Update',
                "update #{@ad.ad_type} ad: #{@ad.region.name}",
                "UPDATE #{@ad.ad_type.upcase} AD: #{ga_info}")
  end

  def track_archive
    track_event('Engagement & Acquisition',
                'Advert Archive',
                "archive #{@ad.ad_type} ad: #{@ad.region.name}",
                "ARCHIVE #{@ad.ad_type.upcase} AD: #{ga_info}")
  end

  def track_contact_reveal
    track_event('Engagement & Acquisition',
                'Phone Reveal',
                "reveal contact details on #{@ad.ad_type} ad: #{@ad.region.name}",
                "REVEAL #{@ad.ad_type.upcase} AD CONTACT: #{ga_info}")
  end

  def track_call
    track_event('Engagement & Acquisition',
                'Phone Call',
                "call made on #{@ad.ad_type} ad: #{@ad.region.name}",
                "CALL #{@ad.ad_type.upcase} AD PHONE")
  end

  def track_text
    track_event('Engagement & Acquisition',
                'Text message',
                "text sent on #{@ad.ad_type} ad: #{@ad.region.name}",
                "TEXT #{@ad.ad_type.upcase} AD PHONE")
  end

  def track_whatsapp
    track_event('Engagement & Acquisition',
                'Whatsapp message',
                "whatsapp sent on #{@ad.ad_type} ad: #{@ad.region.name}",
                "WHATSAPP #{@ad.ad_type.upcase} AD CONTACT")
  end

  def track_favorite
    track_event('Engagement & Acquisition',
                'Advert Added to Favorite',
                "favorite #{@ad.ad_type} ad: #{@ad.region.name}",
                "FAVORITE #{@ad.ad_type.upcase} AD: #{ga_info}")
  end

  def track_failure
    track_event('Engagement & Acquisition',
                'Failed Post Advert Error',
                'failed to post ad',
                "FAILED AD: #{ga_info}")
  end


  private

  def push_to_google_analytics(event_type, options)
    Net::HTTP.get_response URI 'https://www.google-analytics.com/collect?' + {
      v: 1, #Google Analytics Version
      tid: "UA-61742277-1",#tracking ID goes here
      cid: google_analytics_client_id, #Client ID, (555 = anonymous)
      t: event_type
    }.merge(options).to_query if Rails.env.production?
  end
end