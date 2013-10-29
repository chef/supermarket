require 'spec_helper'

class Authorizers::TestPolicy
  include Authorizer
end

describe Supermarket::Authorization do
  subject do
    Class.new do
      include Supermarket::Authorization
      def current_user; end
    end.new
  end

  describe '.included' do
    it 'defines the helper methods on controller' do
      controller = double(:controller, helper_method: true)

      expect(controller).to receive(:helper_method).with(:policy, :can?)
      described_class.included(controller)
    end
  end

  describe '#policy' do
    it 'raises an error when the policy does not exist' do
      expect {
        subject.policy(Class)
      }.to raise_error(Supermarket::Authorization::NotAuthorizedError,
        "No policy exists for Class, so all actions are assumed to be" \
        " unauthorized!"
      )
    end

    it 'creates a new instance' do
      record = double(:record, model_name: 'Test')
      expect(subject.policy(record)).to be_a(Authorizers::TestPolicy)
    end
  end

  describe '#authorized?' do
    it 'uses the current controller action' do
      record = double(:record, model_name: 'Test')
      subject.stub(:can?)
      subject.stub(:params).and_return(action: 'create')

      expect(subject).to receive(:can?).with('create', record)
      subject.authorized?(record)
    end
  end

  describe '#can?' do
    it 'delegates the action to the policy' do
      policy = double(:policy, create?: false)
      subject.stub(:policy).and_return(policy)

      expect(policy).to receive(:create?)
      subject.can?(:create, Class)
    end
  end

  describe '#cannot?' do
    it 'negates the result of #can?' do
      subject.stub(:can?).and_return(true)
      expect(subject.cannot?(:create, Class)).to be_false

      subject.stub(:can?).and_return(false)
      expect(subject.cannot?(:create, Class)).to be_true
    end
  end

  describe '#authorize!' do
    it 'raises an exception if the user is not authorized' do
      subject.stub(:authorized?).and_return(false)
      subject.stub(:params).and_return(action: 'create')

      expect {
        subject.authorize!(Class)
      }.to raise_error(Supermarket::Authorization::NotAuthorizedError,
        "You are not authorized to create Classes!"
      )
    end

    it 'does nothing with the user is authorized' do
      subject.stub(:authorized?).and_return(true)
      expect {
        subject.authorize!(Class)
      }.to_not raise_error
    end
  end
end
