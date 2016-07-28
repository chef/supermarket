require 'spec_helper'

describe Universe do
  let(:cookbook) { 'redis' }
  let(:version) { '1.3.1' }

  context 'when a host is provided' do
    it 'allows you to customize things' do
      opts = {
        host: 'narf.example.com',
        port: 6060,
        protocol: 'https'
      }

      expect(Universe.protocol_host_port(opts)).to eql('https://narf.example.com:6060')
      expect(Universe.download_url(cookbook, version, 'https://narf.example.com:6060')).to eql('https://narf.example.com:6060/api/v1/cookbooks/redis/versions/1.3.1/download')
    end
  end

  context 'when a host is not provided' do
    let(:expected_fqdn) { 'bunniesareadorable' }

    before do
      allow(ENV).to receive(:[]).with('PORT').and_return('6060')
      allow(ENV).to receive(:[]).with('FQDN').and_return(expected_fqdn)
    end

    it 'uses the fqdn environmental variable' do
      opts = {
        port: 6060,
        protocol: 'https'
      }

      expect(Universe.protocol_host_port(opts)).to eql("https://#{expected_fqdn}:6060")
      expect(Universe.download_url(cookbook, version, "https://#{expected_fqdn}:6060")).to eql("https://#{expected_fqdn}:6060/api/v1/cookbooks/redis/versions/1.3.1/download")
    end
  end

  it 'does not print the port if it is not set' do
    opts = {
      host: 'narf.example.com',
      port: nil
    }

    expect(Universe.protocol_host_port(opts)).to eql('http://narf.example.com')
    expect(Universe.download_url(cookbook, version, 'http://narf.example.com')).to eql('http://narf.example.com/api/v1/cookbooks/redis/versions/1.3.1/download')
  end

  describe 'tracking hits' do
    it 'returns 0 if there are no records' do
      expect(Universe.show_hits).to eql(0)
    end

    it 'tracks and displays hits to /universe' do
      2.times { Universe.track_hit }
      expect(Universe.show_hits).to eql(2)
    end
  end
end
