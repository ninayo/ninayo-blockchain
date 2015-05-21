class AddSortOrderToCropTypes < ActiveRecord::Migration
  def change
    add_column :crop_types, :sort_order, :integer
    add_index :crop_types, :sort_order
  end
end
