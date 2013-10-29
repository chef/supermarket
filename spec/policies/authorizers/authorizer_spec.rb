require 'spec_helper'

describe Authorizers::Authorizer, focus: true do
  describe '.included' do
    it 'defines the attr_reader methods on the base' do
      base = double(:base)

      expect(base).to receive(:attr_reader).with(:user)
      expect(base).to receive(:attr_reader).with(:record)
      described_class.included(base)
    end
  end

  let(:user) { double(:user) }
  let(:record) { double(:record) }
  let(:klass) { Class.new { include Authorizers::Authorizer } }

  describe '#initialize' do
    it 'sets the user to an instance variable' do
      instance = klass.new(user, record)
      expect(instance.user).to eq(user)
    end

    it 'sets the user to a new instance if it is nil' do
      instance = klass.new(nil, record)
      expect(instance.user).to be_a(User)
    end
  end

  describe '#method_missing' do
    context 'in development' do
      before { Rails.env.stub(:development?).and_return(true) }

      it 'raises an exception if a method is undefined' do
        expect {
          klass.new(user, record).create?
        }.to raise_error(RuntimeError)
      end
    end

    context 'in production' do
      before { Rails.env.stub(:development?).and_return(false) }
      before { Rails.env.stub(:test?).and_return(false) }

      it 'returns false' do
        instance = klass.new(user, record)
        expect(instance.create?).to be_false
      end
    end
  end
end
