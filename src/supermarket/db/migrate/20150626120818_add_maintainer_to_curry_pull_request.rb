class AddMaintainerToCurryPullRequest < ActiveRecord::Migration[4.2]
  def change
    add_reference :curry_pull_requests, :maintainer, index: true
  end
end
