class EnsureNewGeneratedIndexesExist < ActiveRecord::Migration[4.2]
  def up
    maybe_add_index "accounts", ["uid"], { name: "index_accounts_on_uid", using: :btree }
    maybe_add_index "accounts", ["username"], { name: "index_accounts_on_username", using: :btree }
  end

  def maybe_add_index(table, columns, opts)
    unless index_exists?(table, columns, opts)
      add_index table, columns, opts
    end
  end
end
