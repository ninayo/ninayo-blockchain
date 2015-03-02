json.extract! @ad, :id, :title, :description, :price, :created_at, :updated_at
json.html_url ad_url(@ad, format: :html)
