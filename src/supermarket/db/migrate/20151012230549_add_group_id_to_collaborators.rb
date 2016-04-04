class AddGroupIdToCollaborators < ActiveRecord::Migration
  def change
    add_column :collaborators, :group_id, :integer
  end
end
