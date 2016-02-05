class CreateUserLogs < ActiveRecord::Migration
  def change
    create_table :user_logs do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :action
      t.string :value

      t.timestamps null: false
    end
  end
end
