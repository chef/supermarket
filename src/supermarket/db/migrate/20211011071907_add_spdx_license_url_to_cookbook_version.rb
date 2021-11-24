class AddSpdxLicenseUrlToCookbookVersion < ActiveRecord::Migration[6.1]
  def change
    add_column :cookbook_versions, :spdx_license_url, :string
  end
end
