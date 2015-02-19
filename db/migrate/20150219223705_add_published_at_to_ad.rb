class AddPublishedAtToAd < ActiveRecord::Migration
  def change
    add_column :ads, :published_at, :datetime
  end
end
