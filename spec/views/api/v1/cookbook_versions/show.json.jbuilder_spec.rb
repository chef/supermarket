require 'spec_helper'

describe 'api/v1/cookbook_versions/show' do
  let(:cookbook) { create(:cookbook, name: 'redis') }
  let(:tarball) do
    File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz')
  end

  let(:cookbook_version) do
    create(
      :cookbook_version,
      cookbook: cookbook,
      license: 'MIT',
      version: '1.2.0',
      tarball: tarball
    )
  end

  before do
    assign(:cookbook, cookbook)

    assign(:cookbook_version, cookbook_version)
  end

  it "displays the cookbook version's license" do
    render

    cookbook_version_license = json_body['license']
    expect(cookbook_version_license).to eql('MIT')
  end

  it "displays the cookbook version's license" do
    render

    cookbook_version_version = json_body['version']
    expect(cookbook_version_version).to eql('1.2.0')
  end

  it "displays the cookbook version's cookbook url" do
    render

    cookbook_url = json_body['cookbook']
    expect(cookbook_url).to eql('http://test.host/api/v1/cookbooks/redis')
  end

  it "displays the cookbook version's tarball file size" do
    render

    expect(json_body['tarball_file_size']).to eql(1791)
  end

  it "displays the cookbook version's file url" do
    render

    file_url = URI(json_body['file'])

    expect(file_url.relative?).to eql(false)
    expect(file_url.to_s).to include('cookbooks/redis/versions/1_2_0/download')
  end
end
