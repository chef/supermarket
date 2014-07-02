require 'spec_helper'

describe Universe do
  let(:cookbook) { 'redis' }
  let(:version) { '1.3.1' }

  it 'allows you to customize things' do
    opts = {
      host: 'narf.example.com',
      port: 6060,
      protocol: 'https'
    }

    expect(Universe.protocol_host_port(opts)).to eql('https://narf.example.com:6060')
    expect(Universe.download_url(cookbook, version, 'https://narf.example.com:6060')).to eql('https://narf.example.com:6060/api/v1/cookbooks/redis/versions/1.3.1/download')
  end

  it 'does not print the port if it is not set' do
    opts = {
      host: 'narf.example.com',
      port: nil
    }

    expect(Universe.protocol_host_port(opts)).to eql('http://narf.example.com')
    expect(Universe.download_url(cookbook, version, 'http://narf.example.com')).to eql('http://narf.example.com/api/v1/cookbooks/redis/versions/1.3.1/download')
  end
end
