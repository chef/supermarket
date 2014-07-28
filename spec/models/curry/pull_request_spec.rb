require 'spec_helper'

describe Curry::PullRequest do
  describe 'validations' do
    it { should validate_presence_of(:number) }
    it { should validate_presence_of(:repository_id) }

    it 'ensures pull request numbers are unique per repository' do
      pr = create(:pull_request)
      repo = pr.repository

      errors = repo.pull_requests.new(number: pr.number).tap(&:save).errors

      expect(errors[:number]).to be_present
      expect(errors[:number]).to include('has already been taken')
    end
  end

  describe 'associations' do
    it { should have_many(:comments) }
  end

  describe '#unknown_commit_authors' do
    it 'only returns commit authors who have not signed a CLA' do
      pull_request = create(:pull_request)

      known_author = pull_request.commit_authors.create!(authorized_to_contribute: true)
      unknown_author = pull_request.commit_authors.create!(authorized_to_contribute: false)

      expect(pull_request.unknown_commit_authors.to_a).to eql([unknown_author])
    end
  end

  describe 'deleting a pull request' do
    let(:repository) { create(:repository) }
    let(:pull_request) { create(:pull_request, repository: repository) }

    it "deletes the pull request's pull request commit authors" do
      pull_request.commit_authors.create!(login: 'ein')

      expect do
        pull_request.destroy
      end.to change(Curry::PullRequestCommitAuthor, :count).by(-1)
    end

    it "deletes the pull request's pull request updates" do
      pull_request.pull_request_updates.create!(action: 'opened')

      expect do
        pull_request.destroy
      end.to change(Curry::PullRequestUpdate, :count).by(-1)
    end
  end
end
