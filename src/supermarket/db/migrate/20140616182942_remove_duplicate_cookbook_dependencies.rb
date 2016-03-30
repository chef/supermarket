class RemoveDuplicateCookbookDependencies < ActiveRecord::Migration
  def up
    require 'supermarket/migration/remove_duplicate_cookbook_dependencies'

    Supermarket::Migration::RemoveDuplicateCookbookDependencies.call
  rescue LoadError
    Rails.logger.debug "Silently skipping migration to remove duplicate cookbook dependencies"
  end

  def down
  end
end
