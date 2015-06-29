class AddMaintainerToCurryPullRequest < ActiveRecord::Migration
  def change
    add_reference :curry_pull_requests, :maintainer, index: true
  end
end
