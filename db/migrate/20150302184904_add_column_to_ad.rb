class AddColumnToAd < ActiveRecord::Migration
  def change
    add_reference :ads, :region, index: true
    add_foreign_key :ads, :regions
  end
end
