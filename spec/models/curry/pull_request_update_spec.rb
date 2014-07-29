require 'spec_helper'

describe Curry::PullRequestUpdate do
  describe 'validations' do
    it { should validate_presence_of(:action) }
    it { should validate_presence_of(:pull_request_id) }
  end

  describe '#requires_action?' do
    it 'is false when the action is "closed"' do
      expect(Curry::PullRequestUpdate.new(action: 'closed').requires_action?).to be false
    end

    it 'is true when the action is "opened"' do
      expect(Curry::PullRequestUpdate.new(action: 'opened').requires_action?).to be true
    end

    it 'is true when the action is "reopened"' do
      expect(Curry::PullRequestUpdate.new(action: 'reopened').requires_action?).to be true
    end

    it 'is true when the action is "synchronize"' do
      expect(Curry::PullRequestUpdate.new(action: 'synchronize').requires_action?).to be true
    end
  end
end
