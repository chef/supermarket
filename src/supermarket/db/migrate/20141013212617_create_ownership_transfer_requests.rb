class CreateOwnershipTransferRequests < ActiveRecord::Migration
  def change
    create_table :ownership_transfer_requests do |t|
      t.integer :cookbook_id, null: false
      t.integer :recipient_id, null: false
      t.integer :sender_id, null: false
      t.string :token, null: false
      t.boolean :accepted
      t.timestamps
    end

    add_index :ownership_transfer_requests, :recipient_id
    add_index :ownership_transfer_requests, :cookbook_id
    add_index :ownership_transfer_requests, :token, unique: true
  end
end
