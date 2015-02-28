class CreateAdLogs < ActiveRecord::Migration
  def change
    create_table :ad_logs do |t|
      t.belongs_to :ad, index: true
      t.belongs_to :user, index: true
      t.belongs_to :event_type, index: true
      t.string :description

      t.timestamps null: false
    end
    add_foreign_key :ad_logs, :ads
    add_foreign_key :ad_logs, :users
    add_foreign_key :ad_logs, :event_types
  end
end
