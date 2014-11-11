require 'spec_helper'

describe Supermarket::Host do
  include_context 'env stashing'

  describe '#full_url' do
    it 'generates the correct url when there is no port present' do
      ENV['PORT'] = nil
      ENV['HOST'] = 'example.com'
      ENV['PROTOCOL'] = 'http'

      expect(described_class.full_url).to eql('http://example.com')
    end

    it 'generates the correct url when there is a port present' do
      ENV['PORT'] = '3000'
      ENV['HOST'] = 'example.com'
      ENV['PROTOCOL'] = 'https'

      expect(described_class.full_url).to eql('https://example.com:3000')
    end

    it 'should not display the port in the url if it is 80 or 443' do
      %w(80 443).each do |port|
        ENV['PORT'] = port
        ENV['HOST'] = 'example.com'
        ENV['PROTOCOL'] = 'http'

        expect(described_class.full_url).to eql('http://example.com')
      end
    end
  end
end
