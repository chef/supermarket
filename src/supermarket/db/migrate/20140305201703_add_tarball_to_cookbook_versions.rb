class AddTarballToCookbookVersions < ActiveRecord::Migration[4.2]
  def change
    add_attachment :cookbook_versions, :tarball
  end
end
