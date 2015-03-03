class CreateFavoriteAds < ActiveRecord::Migration
  def change
    create_table :favorite_ads do |t|
      t.belongs_to :ad, index: true
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :favorite_ads, :ads
    add_foreign_key :favorite_ads, :users
  end
end
