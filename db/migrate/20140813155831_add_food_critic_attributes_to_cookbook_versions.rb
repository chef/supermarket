class AddFoodCriticAttributesToCookbookVersions < ActiveRecord::Migration
  def change
    add_column :cookbook_versions, :foodcritic_failure, :boolean, default: nil
    add_column :cookbook_versions, :foodcritic_feedback, :text, default: nil
  end
end
