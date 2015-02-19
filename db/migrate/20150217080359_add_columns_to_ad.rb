class AddColumnsToAd < ActiveRecord::Migration
  def change
    add_column :ads, :volume, :integer
    add_column :ads, :volume_unit, :integer
    add_column :ads, :village, :string
    add_column :ads, :region, :string
    add_reference :ads, :crop_type, index: true
    add_foreign_key :ads, :crop_types
    add_column :ads, :status, :integer

    add_index :ads, :volume
    add_index :ads, :status
  end
end