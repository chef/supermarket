class AddUnauthorizedCommitAuthorsToPullRequestComments < ActiveRecord::Migration
  def change
    change_table :curry_pull_request_comments do |t|
      t.string :unauthorized_commit_authors, array: true, default: []
    end
  end
end
