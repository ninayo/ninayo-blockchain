class CreateAdBuyers < ActiveRecord::Migration
  def change
    create_table :ad_buyers do |t|
      t.belongs_to :ad, index: true
      t.belongs_to :user, index: true
      t.float :price

      t.timestamps null: false
    end
    add_foreign_key :ad_buyers, :ads
    add_foreign_key :ad_buyers, :users
  end
end
