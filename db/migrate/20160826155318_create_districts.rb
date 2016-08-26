class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.integer :region_id,       null: false
      t.string :name,             null: false, index: true
      t.float :lat,               null: false
      t.float :lon,                null: false

      t.timestamps null: false
    end
  end
end
