class AddWhatsappToUsers < ActiveRecord::Migration
  def change
    add_column :users, :whatsapp_id, :string
  end
end
