class RemoveRegionFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :region, :string
  end
end
