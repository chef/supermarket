class RemoveStateColumnFromContributorRequests < ActiveRecord::Migration[4.2]
  def change
    remove_column :contributor_requests, :state, null: false, default: 'pending'
  end
end
