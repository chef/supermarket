class AddStateAttributeToContributorRequests < ActiveRecord::Migration
  def change
    change_table :contributor_requests do |t|
      t.string :state, null: false, default: 'pending'
    end
  end
end
