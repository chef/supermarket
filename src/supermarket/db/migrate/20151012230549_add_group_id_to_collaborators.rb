class AddGroupIdToCollaborators < ActiveRecord::Migration[4.2]
  def change
    add_column :collaborators, :group_id, :integer
  end
end
