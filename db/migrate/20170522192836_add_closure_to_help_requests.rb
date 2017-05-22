class AddClosureToHelpRequests < ActiveRecord::Migration
  def change
    add_column :help_requests, :closed, :boolean, default: false, index: true
  end
end
