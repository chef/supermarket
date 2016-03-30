class RemoveNameFromOrganization < ActiveRecord::Migration
  def change
    remove_column :organizations, :name, :string
  end
end
