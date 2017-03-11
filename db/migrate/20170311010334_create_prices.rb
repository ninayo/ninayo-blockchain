class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :region_id, null: false, index: true
      t.integer :crop_type, null: false, index: true
      t.integer :price, null: false
      t.timestamps null: false, index: true
    end
  end
end
