class DropCurryRelatedTables < ActiveRecord::Migration[6.1]
  def change
    drop_table  :curry_commit_authors, if_exists: true
    drop_table  :curry_pull_request_comments, if_exists: true
    drop_table  :curry_pull_request_commit_authors, if_exists: true
    drop_table  :curry_pull_request_updates, if_exists: true
    drop_table  :curry_pull_requests, if_exists: true
    drop_table  :curry_repositories, if_exists: true
    drop_table  :curry_repository_maintainers, if_exists: true
  end
end
