class AdBuyerPriceToAds < ActiveRecord::Migration
  def change
  	add_column :ads, :buyer_price, :float
  end
end
