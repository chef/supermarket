class RemoveNameFromOrganization < ActiveRecord::Migration[4.2]
  def change
    remove_column :organizations, :name, :string
  end
end
