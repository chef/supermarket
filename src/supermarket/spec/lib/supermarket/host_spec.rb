require 'spec_helper'

describe Supermarket::Host do
  include_context 'env stashing'

  describe '#full_url' do
    it 'generates the correct url when there is no port present' do
      ENV['PORT'] = nil
      ENV['FQDN'] = 'example.com'
      ENV['PROTOCOL'] = 'http'

      expect(described_class.full_url).to eql('http://example.com')
    end

    it 'generates the correct url when there is a port present' do
      ENV['PORT'] = '3000'
      ENV['FQDN'] = 'example.com'
      ENV['PROTOCOL'] = 'https'

      expect(described_class.full_url).to eql('https://example.com:3000')
    end

    it 'should not display the port in the url if it is 80 or 443' do
      %w[80 443].each do |port|
        ENV['PORT'] = port
        ENV['FQDN'] = 'example.com'
        ENV['PROTOCOL'] = 'http'

        expect(described_class.full_url).to eql('http://example.com')
      end
    end
  end

  describe "#secure_session_cookie?" do
    it "returns true if using SSL" do
      allow(ENV).to receive(:[]).with('PROTOCOL').and_return('https')
      expect(described_class.secure_session_cookie?).to be true
    end

    it "returns false if not using SSL" do
      allow(ENV).to receive(:[]).with('PROTOCOL').and_return('http')
      expect(described_class.secure_session_cookie?).to be false
    end
  end
end
