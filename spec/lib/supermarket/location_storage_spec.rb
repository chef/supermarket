require 'spec_helper'

describe Supermarket::LocationStorage do
  subject do
    Class.new(ActionController::Base) do
      include Supermarket::LocationStorage

      def request
        Struct.new(:url).new('http://localhost:3000')
      end

      def session
        @session ||= {}
      end
    end.new
  end

  describe '#store_location!' do
    it 'store the current request location in the session' do
      subject.store_location!

      expect(subject.stored_location).to eql('http://localhost:3000')
    end
  end

  describe '#stored_location' do
    it 'removes the stored location from the session' do
      subject.store_location!
      subject.stored_location

      expect(subject.stored_location).to eql(nil)
    end
  end
end
