class EnsureNewGeneratedIndexesExist < ActiveRecord::Migration[4.2]
  def up
    maybe_add_index "accounts", ["uid"], name: "index_accounts_on_uid", using: :btree
    maybe_add_index "accounts", ["username"], name: "index_accounts_on_username", using: :btree
    maybe_add_index "curry_pull_request_commit_authors", ["commit_author_id"], name: "index_curry_pull_request_commit_authors_on_commit_author_id", using: :btree
    maybe_add_index "curry_pull_request_commit_authors", ["pull_request_id"], name: "index_curry_pull_request_commit_authors_on_pull_request_id", using: :btree
    maybe_add_index "curry_pull_requests", ["repository_id"], name: "index_curry_pull_requests_on_repository_id", using: :btree
  end

  def maybe_add_index(table, columns, opts)
    unless index_exists?(table, columns, opts)
      add_index table, columns, opts
    end
  end
end
