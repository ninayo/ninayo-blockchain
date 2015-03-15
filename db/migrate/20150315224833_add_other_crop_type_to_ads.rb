class AddOtherCropTypeToAds < ActiveRecord::Migration
  def change
    add_column :ads, :other_crop_type, :string
  end
end
