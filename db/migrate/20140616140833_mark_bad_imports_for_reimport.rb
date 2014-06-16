class MarkBadImportsForReimport < ActiveRecord::Migration
  def up
    require 'supermarket/migration/mark_bad_readme_imports_for_reimport'

    Supermarket::Migration::MarkBadReadmeImportsForReimport.call
  rescue LoadError
    Rails.logger.debug 'Silently skipping migration to mark bad README imports'
  end

  def down
  end
end
