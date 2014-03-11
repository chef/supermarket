class AddTarballToCookbookVersions < ActiveRecord::Migration
  def change
    add_attachment :cookbook_versions, :tarball
  end
end
