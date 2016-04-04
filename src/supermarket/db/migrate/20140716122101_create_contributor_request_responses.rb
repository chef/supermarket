class CreateContributorRequestResponses < ActiveRecord::Migration
  def change
    create_table :contributor_request_responses do |t|
      t.integer :contributor_request_id, null: false
      t.string :decision, null: false

      t.timestamps
    end

    add_index :contributor_request_responses, :contributor_request_id, unique: true
  end
end
