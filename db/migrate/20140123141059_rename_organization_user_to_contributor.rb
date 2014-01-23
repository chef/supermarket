class RenameOrganizationUserToContributor < ActiveRecord::Migration
  def change
    rename_table :organization_users, :contributors
  end
end
