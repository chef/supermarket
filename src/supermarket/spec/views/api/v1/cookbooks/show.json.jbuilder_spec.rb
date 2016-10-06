require 'spec_helper'

describe 'api/v1/cookbooks/show' do
  let!(:cookbook) do
    create(
      :cookbook,
      name: 'redis',
      source_url: 'http://example.com',
      issues_url: 'http://example.com',
      deprecated: true,
      replacement: create(:cookbook),
      web_download_count: 2,
      api_download_count: 32
    )
  end

  let!(:cookbook_version_2_0_0) do
    create(
      :cookbook_version,
      cookbook: cookbook,
      description: 'great cookbook',
      version: '2.0.0',
      web_download_count: 1,
      api_download_count: 19
    )
  end

  let!(:cookbook_version_2_1_0) do
    create(
      :cookbook_version,
      cookbook: cookbook,
      description: 'great cookbook',
      version: '2.1.0',
      web_download_count: 1,
      api_download_count: 13
    )
  end

  before do
    create(:cookbook_follower, cookbook: cookbook, user: create(:user))

    assign(
      :cookbook,
      cookbook.reload
    )

    assign(
      :latest_cookbook_version_url,
      'http://test.host/api/v1/cookbooks/redis/versions/2_1_0'
    )

    assign(
      :cookbook_versions_urls,
      [
        'http://test.host/api/v1/cookbooks/redis/versions/2_0_0',
        'http://test.host/api/v1/cookbooks/redis/versions/2_1_0'
      ]
    )

    render
  end

  it "displays the cookbook's name" do
    cookbook_name = json_body['name']
    expect(cookbook_name).to eql('redis')
  end

  it "displays the cookbook's maintainer" do
    cookbook_maintainer = json_body['maintainer']
    expect(cookbook_maintainer).to eql(cookbook.owner.username)
  end

  it "displays the cookbook's description" do
    cookbook_description = json_body['description']
    expect(cookbook_description).to eql('great cookbook')
  end

  it "displays the cookbook's category" do
    cookbook_category = json_body['category']
    expect(cookbook_category).to eql('Other')
  end

  it "displays the url to cookbook's latest version" do
    latest_version_url = json_body['latest_version']
    expect(latest_version_url).
      to eql('http://test.host/api/v1/cookbooks/redis/versions/2.1.0')
  end

  it "displays the cookbook's external url" do
    external_url = json_body['external_url']
    expect(external_url).to eql('http://example.com')
  end

  it "displays the cookbook's deprecation status" do
    deprecated = json_body['deprecated']
    expect(deprecated).to eql(true)
  end

  it "displays the cookbook's replacement cookbook" do
    replacement = json_body['replacement']
    expect(replacement).to eql(api_v1_cookbook_url(cookbook.replacement))
  end

  it "displays the cookbook's versions" do
    versions = json_body['versions']
    expect(versions).to eql(
        [
          'http://test.host/api/v1/cookbooks/redis/versions/2_0_0',
          'http://test.host/api/v1/cookbooks/redis/versions/2_1_0'
        ]
    )
  end

  # let's roll with when the latest cookbook was last updated_at
  it 'displays the date the cookbook was last updated at' do
    expect(DateTime.parse(json_body['updated_at']).to_i).
      to be_within(1).of(cookbook.updated_at.to_i)
  end

  it 'displays the date the cookbook was created at' do
    expect(DateTime.parse(json_body['created_at']).to_i).
      to be_within(1).of(cookbook.created_at.to_i)
  end

  it 'displays the total download count' do
    expect(json_body['metrics']['downloads']['total']).to eql(34)
  end

  it 'displays the download count by version' do
    expect(json_body['metrics']['downloads']['versions']['2.0.0']).to eql(20)
    expect(json_body['metrics']['downloads']['versions']['2.1.0']).to eql(14)
  end

  it 'displays the total followers' do
    expect(json_body['metrics']['followers']).to eql(1)
  end
end
