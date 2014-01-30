class RemovePayloadAndAddNumberActionRepositoryIdToPullRequestUpdate < ActiveRecord::Migration
  def change
    remove_column :curry_pull_request_updates, :payload
    add_column :curry_pull_request_updates, :number, :string
    add_column :curry_pull_request_updates, :action, :string
    add_column :curry_pull_request_updates, :repository_id, :integer, index: true
  end
end
