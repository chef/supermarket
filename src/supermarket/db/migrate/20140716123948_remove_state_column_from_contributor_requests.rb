class RemoveStateColumnFromContributorRequests < ActiveRecord::Migration
  def change
    remove_column :contributor_requests, :state, null: false, default: 'pending'
  end
end
