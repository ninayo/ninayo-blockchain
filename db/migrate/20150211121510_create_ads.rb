class CreateAds < ActiveRecord::Migration
  def change
    create_table :ads do |t|
      t.string :description
      t.float :price

	    t.timestamps null: false
    end
  end
end
