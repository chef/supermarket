class AddAddOwnerAsCollaboratorAttributeToOwnershipTransferRequest < ActiveRecord::Migration[4.2]
  def change
    add_column :ownership_transfer_requests, :add_owner_as_collaborator, :boolean
  end
end
