class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.string :email
      t.integer :sender_id
      t.integer :receiver_id
      t.string :token
      t.timestamps
    end
  end
end
