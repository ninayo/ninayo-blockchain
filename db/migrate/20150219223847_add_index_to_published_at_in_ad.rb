class AddIndexToPublishedAtInAd < ActiveRecord::Migration
  def change
    add_index :ads, :published_at
  end
end
