class AddFinalPriceAndArchivedAtToAd < ActiveRecord::Migration
  def change
    add_column :ads, :final_price, :float
    add_column :ads, :archived_at, :datetime
  end
end
