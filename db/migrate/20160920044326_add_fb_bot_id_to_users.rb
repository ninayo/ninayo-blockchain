class AddFbBotIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fb_bot_id, :string
  end
end
