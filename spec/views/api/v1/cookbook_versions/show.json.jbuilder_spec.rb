require 'spec_helper'

describe 'api/v1/cookbook_versions/show' do
  let(:cookbook) { create(:cookbook, name: 'redis') }
  let(:apt) { create(:cookbook, name: 'apt') }
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
    create(:cookbook_dependency, cookbook_version: cookbook_version, cookbook: apt, name: 'apt', version_constraint: '>= 1.0.0')
    create(:supported_platform, cookbook_version: cookbook_version, name: 'ubuntu', version_constraint: '= 12.04')

    assign(:cookbook, cookbook)
    assign(:cookbook_version, cookbook_version)
    render
  end

  it "displays the cookbook version's dependencies" do
    dependencies = json_body['dependencies']
    expect(dependencies['apt']).to eql('>= 1.0.0')
  end

  it "displays the cookbook version's supported platforms" do
    platforms = json_body['platforms']
    expect(platforms['ubuntu']).to eql('= 12.04')
  end

  it "displays the cookbook version's license" do
    cookbook_version_license = json_body['license']
    expect(cookbook_version_license).to eql('MIT')
  end

  it "displays the cookbook version's license" do
    cookbook_version_version = json_body['version']
    expect(cookbook_version_version).to eql('1.2.0')
  end

  it "displays the cookbook version's cookbook url" do
    cookbook_url = json_body['cookbook']
    expect(cookbook_url).to eql('http://test.host/api/v1/cookbooks/redis')
  end

  it "displays the cookbook version's tarball file size" do
    expect(json_body['tarball_file_size']).to eql(1791)
  end

  it "displays the cookbook version's file url" do
    file_url = URI(json_body['file'])

    expect(file_url.relative?).to eql(false)
    expect(file_url.to_s).to include('cookbooks/redis/versions/1_2_0/download')
  end
end
