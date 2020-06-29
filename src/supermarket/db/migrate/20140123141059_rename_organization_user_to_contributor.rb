class RenameOrganizationUserToContributor < ActiveRecord::Migration[4.2]
  def change
    rename_table :organization_users, :contributors
  end
end
