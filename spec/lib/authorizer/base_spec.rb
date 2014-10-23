require 'spec_helper'

describe Authorizer::Base do
  let(:user) { double(:user) }
  let(:record) { double(:record) }

  describe '#initialize' do
    it 'sets the user' do
      instance = described_class.new(user, record)
      expect(instance.user).to eq(user)
    end

    it 'sets the user to a new instance if it is nil' do
      instance = described_class.new(nil, record)
      expect(instance.user).to be_a(User)
    end

    it 'sets the record' do
      instance = described_class.new(user, record)
      expect(instance.record).to eq(record)
    end
  end

  describe '#method_missing' do
    context 'in development' do
      before { allow(Rails.env).to receive(:development?).and_return(true) }

      it 'raises an exception if a method is undefined' do
        expect { described_class.new(user, record).create? }
        .to raise_error(RuntimeError)
      end
    end

    context 'in production' do
      before { allow(Rails.env).to receive(:development?).and_return(false) }
      before { allow(Rails.env).to receive(:test?).and_return(false) }

      it 'returns false' do
        instance = described_class.new(user, record)
        expect(instance.create?).to be false
      end
    end
  end
end
