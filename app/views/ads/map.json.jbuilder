json.array!(@ads) do |ad|
  json.extract! ad, :id, :title, :price, :village, :region, :lat, :lng
  json.url ad_url(ad, format: :json)
end
