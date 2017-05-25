class AddCreditsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contact_credits, :integer, default: 5
  end
end
