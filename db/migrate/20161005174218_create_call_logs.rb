class CreateCallLogs < ActiveRecord::Migration
  def change
    create_table :call_logs do |t|
      t.integer :caller_id,   null: false
      t.integer :receiver_id, null: false
      t.integer :ad_id,       null: false
      t.timestamps            null: false
    end
  end
end
