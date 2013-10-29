require 'spec_helper'

class TestAuthorizer < Authorizer::Base; end

describe Supermarket::Authorization do
  subject do
    Class.new(ActionController::Base) do
      include Supermarket::Authorization
      def current_user; end
    end.new
  end

  describe '.included' do
    it 'defines the helper methods on controller' do
      controller = double(:controller)

      expect(controller).to receive(:helper_method).with(:authorizer, :can?)
      described_class.included(controller)
    end
  end

  describe '#authorizer' do
    it 'raises an exception when the authorizer does not exist' do
      expect {
        subject.authorizer(Class)
      }.to raise_error(Supermarket::Authorization::NoAuthorizerError,
        "No authorizer exists for Class, so all actions are assumed to be" \
        " unauthorized!"
      )
    end

    it 'creates a new instance' do
      record = double(:record, model_name: 'Test')
      expect(subject.authorizer(record)).to be_a(TestAuthorizer)
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
    it 'delegates the action to the authorizer' do
      authorizer = double(:authorizer, create?: false)
      subject.stub(:authorizer).and_return(authorizer)

      expect(authorizer).to receive(:create?)
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
    it 'raises an error if the user is not authorized' do
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
