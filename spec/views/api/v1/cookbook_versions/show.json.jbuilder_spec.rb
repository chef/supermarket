require 'spec_helper'

describe 'api/v1/cookbook_versions/show' do
  let(:cookbook) { create(:cookbook, name: 'redis') }

  before do
    assign(
      :cookbook,
      cookbook
    )

    assign(
      :cookbook_version,
      create(
        :cookbook_version,
        cookbook: cookbook,
        license: 'MIT',
        version: '1.2.0'
      )
    )
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

  it "displays the cookbook version's tarball file size"
  it "displays the cookbook version's file url"
  it "displays the cookbook version's average rating"

end
