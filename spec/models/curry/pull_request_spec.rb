require 'spec_helper'

describe Curry::PullRequest do

  describe 'validations' do
    it { should validate_presence_of(:number) }
    it { should validate_presence_of(:repository_id) }
  end

  describe '#unknown_commit_authors' do

    it 'only returns commit authors who have not signed a CLA' do
      pull_request = create(:pull_request)

      known_author = pull_request.commit_authors.create!(signed_cla: true)
      unknown_author = pull_request.commit_authors.create!(signed_cla: false)

      expect(pull_request.unknown_commit_authors.to_a).to eql([unknown_author])
    end

  end

end
