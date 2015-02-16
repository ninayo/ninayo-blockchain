class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :role, :integer
    add_column :users, :name, :string
    add_column :users, :phone_number, :string
    add_column :users, :village, :string
    add_column :users, :region, :string
    add_column :users, :position, :point
    add_column :users, :language, :string
  end
end
