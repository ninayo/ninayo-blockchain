class AddDistrictAndWardToUsers < ActiveRecord::Migration
  def change
    add_column :users, :district_id, :integer
    add_column :users, :ward_id, :integer
  end
end
