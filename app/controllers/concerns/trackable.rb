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
    cookies["_ga"].split(".").last(2).join(".")
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