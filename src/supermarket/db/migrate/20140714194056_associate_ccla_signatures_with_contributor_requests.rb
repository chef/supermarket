class AssociateCclaSignaturesWithContributorRequests < ActiveRecord::Migration
  def change
    change_table :contributor_requests do |t|
      t.integer :ccla_signature_id, null: false
    end
  end
end
