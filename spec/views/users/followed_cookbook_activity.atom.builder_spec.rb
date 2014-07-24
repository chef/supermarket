require 'spec_helper'

describe 'users/followed_cookbook_activity.atom.builder' do
  let(:test_cookbook) do
    create(
      :cookbook,
      name: 'test',
      cookbook_versions: [
        create(:cookbook_version, description: 'test cookbook')
      ],
      cookbook_versions_count: 0
    )
  end

  let(:test_cookbook2) do
    create(
      :cookbook,
      name: 'test-2',
      cookbook_versions: [
        create(:cookbook_version, description: 'test cookbook')
      ],
      cookbook_versions_count: 0
    )
  end

  before do
    assign(
      :followed_cookbook_activity,
      [test_cookbook.cookbook_versions.first, test_cookbook2.cookbook_versions.first]
    )

    assign(:user, double(User, username: 'johndoe'))
  end

  it 'displays the feed title' do
    render

    expect(xml_body['feed']['title']).to eql("johndoe's Followed Cookbook Activity")
  end

  it 'displays when the feed was updated' do
    render

    expect(Date.parse(xml_body['feed']['updated'])).to_not be_nil
  end

  it 'displays followed cookbook activity entries' do
    render

    expect(xml_body['feed']['entry'].count).to eql(2)
  end

  it 'displays information about cookbook activity' do
    render

    activity = xml_body['feed']['entry'].first

    expect(activity['title']).to eql(test_cookbook.name)
    expect(activity['maintainer']).to eql(test_cookbook.maintainer)
    expect(activity['description']).to eql(test_cookbook.description)
    expect(activity['version']).to eql(test_cookbook.cookbook_versions.first.version)
    expect(activity['link']['href']).
      to eql(cookbook_version_url(test_cookbook, test_cookbook.cookbook_versions.first.version))
  end
end
