class AddCookbookFollowersCountToCookbooks < ActiveRecord::Migration
  def change
    add_column :cookbooks, :cookbook_followers_count, :integer, default: 0
  end
end
