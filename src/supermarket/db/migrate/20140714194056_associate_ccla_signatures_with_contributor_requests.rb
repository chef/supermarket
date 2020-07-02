class AssociateCclaSignaturesWithContributorRequests < ActiveRecord::Migration[4.2]
  def change
    change_table :contributor_requests do |t|
      t.integer :ccla_signature_id, null: false
    end
  end
end
