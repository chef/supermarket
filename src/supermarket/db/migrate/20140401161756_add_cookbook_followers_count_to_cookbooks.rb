class AddCookbookFollowersCountToCookbooks < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbooks, :cookbook_followers_count, :integer, default: 0
  end
end
