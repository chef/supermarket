class RenameUnknownPullRequestCommittersToPullRequestCommitAuthors < ActiveRecord::Migration
  def change
    rename_table :curry_unknown_pull_request_committers, :curry_pull_request_commit_authors
    rename_index :curry_pull_request_commit_authors, 'idx_curry_unk_pull_request_committers_unk_committer_id',
      'index_curry_pull_request_commit_authors_on_unknown_committer_id'
  end
end
