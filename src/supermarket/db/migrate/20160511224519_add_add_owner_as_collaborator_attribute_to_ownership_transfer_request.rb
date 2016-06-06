class AddAddOwnerAsCollaboratorAttributeToOwnershipTransferRequest < ActiveRecord::Migration
  def change
    add_column :ownership_transfer_requests, :add_owner_as_collaborator, :boolean
  end
end
