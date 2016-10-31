class AddNegotiableToAds < ActiveRecord::Migration
  def change
    add_column :ads, :negotiable, :boolean, default: true
  end
end
