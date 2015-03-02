class AddPropertiesToAd < ActiveRecord::Migration
  def change
    add_column :ads, :lat, :float
    add_column :ads, :lng, :float
  end
end
