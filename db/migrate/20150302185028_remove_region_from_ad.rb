class RemoveRegionFromAd < ActiveRecord::Migration
  def change
    remove_column :ads, :region, :string
  end
end
