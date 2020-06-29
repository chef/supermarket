class CreateCookbookDependencies < ActiveRecord::Migration[4.2]
  def change
    create_table :cookbook_dependencies do |t|
      t.string :name, null: false
      t.string :version_constraint, null: false, default: '>= 0.0.0'
      t.references :cookbook_version, index: true, null: false
      t.timestamps
    end
  end
end
