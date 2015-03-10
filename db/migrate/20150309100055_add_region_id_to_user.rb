class AddRegionIdToUser < ActiveRecord::Migration
  def change
    add_reference :users, :region, index: true
    add_foreign_key :users, :regions
  end
end
