class AddUserToCookbookVersion < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbook_versions, :user_id, :integer
  end
end
