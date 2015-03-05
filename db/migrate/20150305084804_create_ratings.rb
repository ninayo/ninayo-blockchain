class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :score
      t.integer :rater_id, index: true
      t.belongs_to :user, index: true
      t.belongs_to :ad, index: true
      t.integer :role

      t.timestamps null: false
    end

    add_foreign_key :ratings, :ads
    add_foreign_key :ratings, :users
    add_foreign_key :ratings, :users, column: :rater_id
  end
end
