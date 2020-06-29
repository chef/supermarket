class CreateCurryRepositories < ActiveRecord::Migration[4.2]
  def change
    create_table :curry_repositories do |t|
      t.string :owner
      t.string :name

      t.timestamps
    end
  end
end
