class CreateSupportedPlatforms < ActiveRecord::Migration
  def change
    create_table :supported_platforms do |t|
      t.string :name, null: false
      t.string :version_constraint, null: false, default: '>= 0.0.0'
      t.references :cookbook_version, index: true, null: false

      t.timestamps
    end
  end
end
