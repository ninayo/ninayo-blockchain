class AddSellerRatingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :seller_rating, :float
    add_column :users, :buyer_rating, :float
  end
end
