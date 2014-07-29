require 'spec_helper'

describe Curry::PullRequestComment do
  describe '.with_github_id' do
    it 'returns only comments with the given github_id' do
      comments = 2.times.map do |i|
        Curry::PullRequestComment.create!(github_id: i, pull_request_id: i)
      end

      scope = Curry::PullRequestComment.with_github_id(0)

      expect(scope.to_a).to eql(comments.first(1))
    end
  end

  it 'defaults unauthorized_commit_authors to an empty array' do
    comment = Curry::PullRequestComment.create(github_id: 1, pull_request_id: 1)

    expect(comment.unauthorized_commit_authors).to eql([])
  end
end
