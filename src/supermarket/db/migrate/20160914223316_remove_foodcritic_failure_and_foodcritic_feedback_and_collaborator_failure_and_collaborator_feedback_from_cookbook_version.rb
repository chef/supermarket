class RemoveFoodcriticFailureAndFoodcriticFeedbackAndCollaboratorFailureAndCollaboratorFeedbackFromCookbookVersion < ActiveRecord::Migration[4.2]
  def change
    remove_column :cookbook_versions, :foodcritic_failure, :boolean
    remove_column :cookbook_versions, :foodcritic_feedback, :text
    remove_column :cookbook_versions, :collaborator_failure, :boolean
    remove_column :cookbook_versions, :collaborator_feedback, :text
  end
end
