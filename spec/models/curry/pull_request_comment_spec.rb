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
end
