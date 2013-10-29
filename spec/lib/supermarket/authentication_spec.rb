require 'spec_helper'

describe Supermarket::Authentication do
  subject do
    Class.new { include Supermarket::Authentication }.new
  end

  describe '.included' do
    it 'defines the helper methods on controller' do
      controller = double(:controller, helper_method: true)

      expect(controller).to receive(:helper_method)
        .with(:current_user, :logged_in?)
      described_class.included(controller)
    end
  end

  describe '#current_user' do
    it 'returns nil if there is no session' do
      subject.stub(:session).and_return({})
      expect(subject.current_user).to be_nil
    end

    it 'finds the user by the session' do
      user = double(:user)
      User.stub(:find).with(1).and_return(user)
      subject.stub(:session).and_return(user_id: 1)

      expect(subject.current_user).to be(user)
    end
  end

  describe '#logged_in?' do
    it 'returns true when there is a current_user' do
      subject.stub(:current_user).and_return(true)
      expect(subject.logged_in?).to be_true
    end

    it 'returns false when there is no current_user' do
      subject.stub(:current_user).and_return(false)
      expect(subject.logged_in?).to be_false
    end
  end
end
