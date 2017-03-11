class ChangePriceCropType < ActiveRecord::Migration
  def change
    rename_column :prices, :crop_type, :crop_type_id
  end
end
