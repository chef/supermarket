class AddCollaboratorFailureAndFeedbackToCookbookVersion < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbook_versions, :collaborator_failure, :boolean
    add_column :cookbook_versions, :collaborator_feedback, :text
  end
end
