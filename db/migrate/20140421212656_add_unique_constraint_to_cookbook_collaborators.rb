class AddUniqueConstraintToCookbookCollaborators < ActiveRecord::Migration
  def change
    add_index :cookbook_collaborators, [:user_id, :cookbook_id], unique: true
  end
end
