class CreateCookbookVersions < ActiveRecord::Migration[4.2]
  def change
    create_table :cookbook_versions do |t|
      t.integer :cookbook_id
      t.text :description
      t.string :license
      t.string :version
      t.string :file_url
      t.string :file_size

      t.timestamps
    end
  end
end
