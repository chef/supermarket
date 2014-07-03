require 'spec_helper'

describe Curry::PullRequestCommitAuthor do
  describe 'validations' do
    it 'ensures that commit authors are only present once per PR' do
      pull_request = create(:pull_request)
      commit_author = pull_request.commit_authors.create!(login: 'jsmith')

      join = Curry::PullRequestCommitAuthor.create(
        pull_request: pull_request,
        commit_author: commit_author
      )

      expect(join.errors[:commit_author_id]).to be_present
      expect(join.errors[:commit_author_id]).to include('has already been taken')
    end
  end
end
