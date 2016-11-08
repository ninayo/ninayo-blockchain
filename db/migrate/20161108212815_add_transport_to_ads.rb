class AddTransportToAds < ActiveRecord::Migration
  def change
    add_column :ads, :transport_type, :string
  end
end
