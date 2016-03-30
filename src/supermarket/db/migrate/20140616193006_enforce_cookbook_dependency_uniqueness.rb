class EnforceCookbookDependencyUniqueness < ActiveRecord::Migration
  def change
    add_index(
      :cookbook_dependencies,
      [:cookbook_version_id, :name, :version_constraint],
      name: 'cookbook_dependencies_unique_by_name_and_constraint',
      unique: true
    )
  end
end
