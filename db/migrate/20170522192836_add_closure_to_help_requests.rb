class AddClosureToHelpRequests < ActiveRecord::Migration
  def change
    add_column :help_requests, :closed, :boolean, index: true
  end
end
