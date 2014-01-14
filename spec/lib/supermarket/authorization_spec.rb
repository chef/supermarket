require 'spec_helper'

class TestAuthorizer < Authorizer::Base; end

class ReadOnly

  class Policy

    def initialize(*_) ; end

    def show?
      true
    end

    def edit?
      false
    end

  end

  def policy_class
    Policy
  end

end

describe Supermarket::Authorization do
  subject do
    Class.new(ActionController::Base) do
      include Supermarket::Authorization
      def current_user; end
    end.new
  end

  let(:read_only_object) { ReadOnly.new }

  describe '.included' do
    it 'defines the helper methods on controller' do
      controller = double(:controller)

      expect(controller).to receive(:helper_method).with(:can?)
      described_class.included(controller)
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
    it 'returns false if the user cannot perform the given action' do
      expect(subject.can?(:edit, read_only_object)).to eql(false)
    end
  end

  describe '#cannot?' do
    it 'negates the result of #can?' do
      expect(subject.cannot?(:edit, read_only_object)).to be_true
      expect(subject.cannot?(:show, read_only_object)).to be_false
    end
  end

  describe '#authorize!' do
    it 'raises an error if the user is not authorized' do
      subject.stub(:params).and_return(action: 'edit')

      expect {
        subject.authorize!(read_only_object)
      }.to raise_error(Supermarket::Authorization::NotAuthorizedError)
    end

    it 'does nothing with the user is authorized' do
      subject.stub(:params).and_return(action: 'show')

      expect {
        subject.authorize!(read_only_object)
      }.to_not raise_error
    end
  end
end
