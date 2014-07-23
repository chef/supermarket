require 'spec_helper'

describe Curry::PullRequestUpdate do
  describe 'validations' do
    it { should validate_presence_of(:action) }
    it { should validate_presence_of(:pull_request_id) }
  end

  describe '#closing?' do
    it 'is true when the action is "closed"' do
      expect(Curry::PullRequestUpdate.new(action: 'closed').closing?).to be true
    end

    it 'is false when the action is not "closed"' do
      expect(Curry::PullRequestUpdate.new(action: 'opened').closing?).to be false
    end
  end
end
