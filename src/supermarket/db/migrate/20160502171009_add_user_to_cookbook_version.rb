class AddUserToCookbookVersion < ActiveRecord::Migration
  def change
    add_column :cookbook_versions, :user_id, :integer
  end
end
