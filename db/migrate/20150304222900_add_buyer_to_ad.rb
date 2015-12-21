class AddBuyerToAd < ActiveRecord::Migration
  def change
  	add_column :ads, :buyer_id, :integer, index:true
    #add_foreign_key :ads, :users
  end
end
