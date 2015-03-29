class DropAdBuyers < ActiveRecord::Migration
  def change
  	drop_table :ad_buyers
  end
end
