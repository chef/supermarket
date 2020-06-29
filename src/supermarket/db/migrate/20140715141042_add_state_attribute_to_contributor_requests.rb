class AddStateAttributeToContributorRequests < ActiveRecord::Migration[4.2]
  def change
    change_table :contributor_requests do |t|
      t.string :state, null: false, default: 'pending'
    end
  end
end
