class CreateWards < ActiveRecord::Migration
  def change
    create_table :wards do |t|
      t.integer :district_id,   null: false
      t.string :name,           null: false, index: true
      t.timestamps null: false
    end
  end
end
