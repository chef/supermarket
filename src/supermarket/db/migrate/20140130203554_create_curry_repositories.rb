class CreateCurryRepositories < ActiveRecord::Migration
  def change
    create_table :curry_repositories do |t|
      t.string :owner
      t.string :name

      t.timestamps
    end
  end
end
