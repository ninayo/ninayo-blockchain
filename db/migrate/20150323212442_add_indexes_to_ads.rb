class AddIndexesToAds < ActiveRecord::Migration
  def change
  	add_index :ads, :price
  end
end
