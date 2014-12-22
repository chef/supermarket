require 'spec_helper'

describe 'users/followed_cookbook_activity.atom.builder' do
  let!(:test_cookbook_5_0) do
    create(
      :cookbook_version,
      version: '5.0',
      description: 'this cookbook is so rad',
      changelog: 'we added so much stuff!',
      changelog_extension: 'md'
    )
  end

  let!(:test_cookbook) do
    create(
      :cookbook,
      name: 'test',
      cookbook_versions_count: 0,
      cookbook_versions: [test_cookbook_5_0]
    )
  end

  let!(:test_cookbook2) do
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
    render
  end

  it 'displays the feed title' do
    expect(xml_body['feed']['title']).to eql("johndoe's Followed Cookbook Activity")
  end

  it 'displays when the feed was updated' do
    expect(Date.parse(xml_body['feed']['updated'])).to_not be_nil
  end

  it 'displays followed cookbook activity entries' do
    expect(xml_body['feed']['entry'].count).to eql(2)
  end

  it 'displays information about cookbook activity' do
    activity = xml_body['feed']['entry'].first

    expect(activity['title']).to match(/#{test_cookbook.name}/)
    expect(activity['content']).to match(/this cookbook is so rad/)
    expect(activity['content']).to match(/we added so much stuff/)
    expect(activity['author']['name']).to eql(test_cookbook.maintainer)
    expect(activity['author']['uri']).to eql(user_url(test_cookbook.owner))
    expect(activity['link']['href']).
      to eql(cookbook_version_url(test_cookbook, test_cookbook.cookbook_versions.first.version))
  end
end
