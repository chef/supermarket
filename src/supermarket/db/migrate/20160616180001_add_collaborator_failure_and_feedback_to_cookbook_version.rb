class AddCollaboratorFailureAndFeedbackToCookbookVersion < ActiveRecord::Migration
  def change
    add_column :cookbook_versions, :collaborator_failure, :boolean
    add_column :cookbook_versions, :collaborator_feedback, :text
  end
end
