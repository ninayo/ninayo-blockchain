class CreateHelpRequests < ActiveRecord::Migration
  def change
    create_table :help_requests do |t|
      t.string :email
      t.string :phone_number, null: false
      t.text :body, null: false
      t.integer :user_id
      t.integer :request_type, null: false, index: true

      t.timestamps null: false
    end
  end
end
