require 'spec_helper'

describe 'cookbooks/index.atom.builder' do
  before do
    assign(
      :cookbooks,
      [
        create(
          :cookbook,
          name: 'test',
          description: 'test cookbook',
          maintainer: 'Chef Software, Inc.'
        ),
        create(
          :cookbook,
          name: 'test-2',
          description: 'test cookbook',
          maintainer: 'Chef Software, Inc.'
        )
      ]
    )
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
    expect(cookbook['maintainer']).to eql('Chef Software, Inc.')
    expect(cookbook['description']).to eql('test cookbook')
    expect(cookbook['url']).to eql('http://test.host/cookbooks/test')
  end
end
