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

    route = routes.api_v1_cookbook_version_download_url(
      cookbook,
      version,
      opts
    )

    expect(Universe.download_path(cookbook.name, version.version, opts)).to eql(route)
  end
end
