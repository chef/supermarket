require 'spec_helper'

describe Universe do
  let(:cookbook) { create(:cookbook) }
  let(:routes) { Rails.application.routes.url_helpers }
  let(:version) { cookbook.cookbook_versions.first }

  it 'allows you to customize things' do
    opts = {
      host: 'narf.com',
      port: 6060,
      protocol: 'https'
    }

    expect(Universe.download_path(cookbook.name, version.version, opts)).to eql('https://narf.com:6060/api/v1')
  end

  it 'does not print the port if it is not set' do
    opts = {
      host: 'narf.com'
    }

    expect(Universe.download_path(cookbook.name, version.version, opts)).to eql('http://narf.com/api/v1')
  end
end
