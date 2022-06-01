class EnsureNewGeneratedIndexesExist < ActiveRecord::Migration[6.1]
  def up
    add_index "accounts", ["uid"], name: "index_accounts_on_uid", using: :btree, if_not_exists: true
    add_index "accounts", ["username"], name: "index_accounts_on_username", using: :btree, if_not_exists: true
  end
end
