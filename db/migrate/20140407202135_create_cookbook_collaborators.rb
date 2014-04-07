class CreateCookbookCollaborators < ActiveRecord::Migration
  def change
    create_table :cookbook_collaborators do |t|
      t.references :cookbook
      t.references :user
      t.timestamps
    end
  end
end
