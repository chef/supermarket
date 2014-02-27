require 'spec_helper'

describe 'api/v1/cookbooks/show' do
  let(:cookbook) do
    create(
      :cookbook,
      name: 'redis',
      maintainer: 'slime',
      description: 'great cookbook',
      category: 'datastore',
      external_url: 'http://example.com',
      deprecated: false
    )
  end

  before do
    assign(
      :cookbook,
      cookbook
    )

    create(
      :cookbook_version,
      cookbook: cookbook,
      version: '1.1.0'
    )
  end

  it "displays the cookbook's name" do
    render

    cookbook_name = json_body['name']
    expect(cookbook_name).to eql('redis')
  end

  it "displays the cookbook's maintainer" do
    render

    cookbook_maintainer = json_body['maintainer']
    expect(cookbook_maintainer).to eql('slime')
  end

  it "displays the cookbook's description" do
    render

    cookbook_description = json_body['description']
    expect(cookbook_description).to eql('great cookbook')
  end

  it "displays the cookbook's category" do
    render

    cookbook_category = json_body['category']
    expect(cookbook_category).to eql('datastore')
  end

  it "displays the url to cookbook's latest version" do
    render

    latest_version_url = json_body['latest_version']
    expect(latest_version_url).
      to eql('http://test.host/api/v1/cookbooks/redis/versions/1_1_0')
  end

  it "displays the cookbook's external url" do
    render

    external_url = json_body['external_url']
    expect(external_url).to eql('http://example.com')
  end

  it "displays the cookbook's deprecation status" do
    render

    deprecated = json_body['deprecated']
    expect(deprecated).to eql(false)
  end

  it "displays the cookbook's versions" do
    create(
      :cookbook_version,
      cookbook: cookbook,
      version: '1.0.0'
    )

    render

    versions = json_body['versions']
    expect(versions).to eql(
        [
          'http://test.host/api/v1/cookbooks/redis/versions/1_0_0',
          'http://test.host/api/v1/cookbooks/redis/versions/1_1_0'
        ]
    )
  end

  # let's roll with when the latest cookbook was last updated_at
  it "displays the date the cookbook was last updated at" do
    render

    updated_at = json_body['updated_at']
    expect(DateTime.parse(updated_at).to_i).to eql(cookbook.created_at.to_i)
  end

  it "displays the date the cookbook was created at" do
    render

    created_at = json_body['created_at']
    expect(DateTime.parse(created_at).to_i).
      to eql(cookbook.get_version!('latest').updated_at.to_i)
  end

  # TODO: add this when ratings are implemented
  it "displays the cookbook's average rating"

end
