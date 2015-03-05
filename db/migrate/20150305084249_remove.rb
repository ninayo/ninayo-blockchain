class Remove < ActiveRecord::Migration
  def change
  		remove_column :users, :position
  end
end
