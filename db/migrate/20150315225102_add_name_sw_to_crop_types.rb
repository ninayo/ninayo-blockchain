class AddNameSwToCropTypes < ActiveRecord::Migration
  def change
    add_column :crop_types, :name_sw, :string
  end
end
