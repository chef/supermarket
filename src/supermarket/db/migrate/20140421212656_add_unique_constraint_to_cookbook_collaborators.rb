class AddUniqueConstraintToCookbookCollaborators < ActiveRecord::Migration[4.2]
  def change
    add_index :cookbook_collaborators, [:user_id, :cookbook_id], unique: true
  end
end
