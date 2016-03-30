class MakeCollaboratorsPolymorphic < ActiveRecord::Migration
  def up
    remove_index :cookbook_collaborators, name: 'index_cookbook_collaborators_on_user_id_and_cookbook_id'
    add_column :cookbook_collaborators, :resourceable_type, :string
    rename_column :cookbook_collaborators, :cookbook_id, :resourceable_id
    add_index :cookbook_collaborators, [:user_id, :resourceable_type, :resourceable_id], unique: true, name: 'index_cookbook_collaborators_on_user_id_and_resourceable'
    rename_table :cookbook_collaborators, :collaborators

    Collaborator.update_all(resourceable_type: 'Cookbook')
  end

  def down
    remove_column :collaborators, :resourceable_type
    rename_column :collaborators, :resourceable_id, :cookbook_id
    add_index :collaborators, [:user_id, :cookbook_id], unique: true
    rename_table :collaborators, :cookbook_collaborators
  end
end
