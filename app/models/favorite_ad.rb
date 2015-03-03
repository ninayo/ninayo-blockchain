class FavoriteAd < ActiveRecord::Base
  belongs_to :ad
  belongs_to :user
end
