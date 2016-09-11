class AddWardAndDistrictToAds < ActiveRecord::Migration
  def change
    add_column :ads, :district_id, :integer
    add_column :ads, :ward_id, :integer
  end
end
