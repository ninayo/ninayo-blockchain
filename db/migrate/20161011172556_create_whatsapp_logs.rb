class CreateWhatsappLogs < ActiveRecord::Migration
  def change
    create_table :whatsapp_logs do |t|
      t.integer :sender_id,   null: false
      t.integer :receiver_id, null: false
      t.integer :ad_id,       null: false
      t.timestamps            null: false
    end
  end
end
