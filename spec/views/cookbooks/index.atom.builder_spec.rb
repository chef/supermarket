require 'spec_helper'

describe 'cookbooks/index.atom.builder' do
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
    assign(:cookbooks, [test_cookbook, test_cookbook2])
  end

  it 'displays the feed title' do
    render

    expect(xml_body['feed']['title']).to eql('Cookbooks')
  end

  it 'displays when the feed was updated' do
    render

    expect(Date.parse(xml_body['feed']['updated'])).to_not be_nil
  end

  it 'displays cookbook entries' do
    render

    expect(xml_body['feed']['entry'].count).to eql(2)
  end

  it 'displays information about a cookbook' do
    render

    cookbook = xml_body['feed']['entry'].first

    expect(cookbook['title']).to eql('test')
    expect(cookbook['author']['name']).to eql(test_cookbook.owner.username)
    expect(cookbook['author']['uri']).to eql(user_url(test_cookbook.owner))
    expect(cookbook['content']).to eql('test cookbook')
    expect(cookbook['link']['href']).to eql('http://test.host/cookbooks/test')
  end
end
