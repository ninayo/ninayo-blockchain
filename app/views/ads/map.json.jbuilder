json.array!(@ads) do |ad|
  json.extract! ad, :id, :title, :price, :lat, :lng
  json.url infopanel_path(ad)
  #json.url ad_url(ad, format: :json)
  #json.html_url ad_url(ad, format: :html)
end
