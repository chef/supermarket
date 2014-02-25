require 'spec_helper'

describe 'api/v1/cookbooks/index' do

  it 'displays the starting offset' do
    assign(:start, 0)

    render

    expect(json_body['start']).to eql(0)
  end

  it 'displays the total number of cookbooks' do
    assign(:total, 666)

    render

    expect(json_body['total']).to eql(666)
  end

  it 'displays an array of cookbooks' do
    assign(
      :cookbooks,
      [
        create(
          :cookbook,
          name: 'test',
          description: 'test cookbook',
          maintainer: 'Chef Software, Inc.'
        )
      ]
    )

    render

    cookbook = json_body['items'].first

    expect(cookbook['cookbook_name']).to eql('test')
    expect(cookbook['cookbook_maintainer']).to eql('Chef Software, Inc.')
    expect(cookbook['cookbook_description']).to eql('test cookbook')
    expect(cookbook['cookbook']).to eql('http://test.host/api/v1/cookbooks/test')
  end

end
