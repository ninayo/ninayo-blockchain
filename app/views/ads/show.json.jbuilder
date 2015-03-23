json.extract! @ad, :id, :title, :description, :price, :volume, :volume_unit, :created_at, :updated_at, :user
json.html_url ad_url(@ad, format: :html)
json.seller_score @ad.user.seller_score
