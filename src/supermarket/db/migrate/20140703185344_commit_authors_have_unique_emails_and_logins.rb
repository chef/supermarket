class CommitAuthorsHaveUniqueEmailsAndLogins < ActiveRecord::Migration
  def change
    emails = Curry::CommitAuthor.with_known_email.pluck(:email)
    logins = Curry::CommitAuthor.with_known_login.pluck(:login)

    duplicates(emails) do |email|
      keep_the_most_recent_author! Curry::CommitAuthor.where(email: email)
    end

    duplicates(logins) do |login|
      keep_the_most_recent_author! Curry::CommitAuthor.where(login: login)
    end

    joins = Curry::PullRequestCommitAuthor.all.map do |join|
      [join.commit_author_id, join.pull_request_id]
    end

    duplicates(joins) do |commit_author_id, pull_request_id|
      join_models = Curry::PullRequestCommitAuthor.where(
        commit_author_id: commit_author_id,
        pull_request_id: pull_request_id
      ).order(:id).to_a

      join_models.tap(&:pop).each(&:destroy)
    end

    add_index :curry_commit_authors, :login, unique: true
    add_index :curry_commit_authors, :email, unique: true
    add_index :curry_pull_request_commit_authors, [:commit_author_id, :pull_request_id], unique: true, name: 'curry_pr_commit_author_ids'
  end

  private

  def duplicates(collection)
    collection.
      group_by { |_| _ }.
      each { |item, items| yield item if items.count > 1 }
  end

  def keep_the_most_recent_author!(scope)
    authors = scope.order(:id).to_a
    keeper = authors.last

    authors.reject { |author| author == keeper }.each do |duplicate|
      duplicate.pull_requests.each do |pull_request|
        keeper.pull_requests << pull_request
      end

      duplicate.destroy
    end
  end
end
