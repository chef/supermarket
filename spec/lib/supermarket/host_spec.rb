require 'spec_helper'

describe Supermarket::Host do
  describe '#full_url' do
    it 'generates the correct url when there is no port present' do
      port = ENV['PORT']
      ENV['PORT'] = nil
      expect(ENV['PORT']).to be_nil
      expect(ENV['HOST']).to eql('localhost')
      expect(ENV['PROTOCOL']).to eql('http')
      expect(described_class.full_url).to eql('http://localhost')
      ENV['PORT'] = port
    end

    it 'generates the correct url when there is a port present' do
      expect(ENV['PORT']).to eql('3000')
      expect(ENV['HOST']).to eql('localhost')
      expect(ENV['PROTOCOL']).to eql('http')
      expect(described_class.full_url).to eql('http://localhost:3000')
    end
  end
end
