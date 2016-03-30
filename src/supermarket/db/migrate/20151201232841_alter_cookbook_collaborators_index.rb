class AlterCookbookCollaboratorsIndex < ActiveRecord::Migration
  def change
    remove_index :collaborators, name: 'index_cookbook_collaborators_on_user_id_and_resourceable'
    add_index :collaborators, [:user_id, :resourceable_type, :resourceable_id, :group_id], unique: true, name: 'index_collaborators_on_user_id_and_group_id_and_resourceable'
  end
end
