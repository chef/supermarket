require 'spec_helper'

describe 'api/v1/cookbooks/index' do
  it 'displays the starting offset' do
    assign(:start, 0)

    render

    expect(json_body['start']).to eql(0)
  end

  it 'displays the total number of cookbooks' do
    assign(:total, 9001)

    render

    expect(json_body['total']).to eql(9001)
  end

  let(:cookbook_record) do
    create(
      :cookbook,
      name: 'test',
      cookbook_versions: [
        create(
          :cookbook_version,
          description: 'test cookbook'
        )
      ],
      cookbook_versions_count: 0
    )
  end

  it 'displays an array of cookbooks' do
    assign(:cookbooks, [cookbook_record])

    render

    cookbook = json_body['items'].first

    expect(cookbook['cookbook_name']).to eql('test')
    expect(cookbook['cookbook_maintainer']).to eql(cookbook_record.owner.username)
    expect(cookbook['cookbook_description']).to eql('test cookbook')
    expect(cookbook['cookbook']).to eql('http://test.host/api/v1/cookbooks/test')
  end
end
