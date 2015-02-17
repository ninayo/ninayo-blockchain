class RemoveTitleFromAd < ActiveRecord::Migration
  def change
  	remove_column :ads, :title
  end
end
