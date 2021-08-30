class DropCurryRelatedTables < ActiveRecord::Migration[6.1]
  def change
    drop_table  :curry_commit_authors
    drop_table  :curry_pull_request_comments
    drop_table  :curry_pull_request_commit_authors
    drop_table  :curry_pull_request_updates
    drop_table  :curry_pull_requests
    drop_table  :curry_repositories
    drop_table  :curry_repository_maintainers
  end
end
