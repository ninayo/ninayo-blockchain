class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :author_id, null: false, index: true
      t.integer :ad_id, null: false, index: true
      t.text :body, null: false

      t.timestamps null: false
    end
  end
end
