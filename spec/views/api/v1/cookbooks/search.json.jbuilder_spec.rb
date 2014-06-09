require 'spec_helper'

describe 'api/v1/cookbooks/search' do
  let(:cookbook_record) { create(:cookbook, name: 'redis') }

  before do
    assign(:total, 1)
    assign(:results, [cookbook_record])
    assign(:start, 1)
  end

  it 'displays the total number of results' do
    render

    total = json_body['total']
    expect(total).to eql(1)
  end

  it 'displays an array of the results' do
    render

    cookbook = json_body['items'].first

    expect(cookbook['cookbook_name']).to eql('redis')
    expect(cookbook['cookbook_maintainer']).to eql(cookbook_record.owner.username)
    expect(cookbook['cookbook_description']).to eql('An awesome cookbook!')
    expect(cookbook['cookbook']).to eql('http://test.host/api/v1/cookbooks/redis')
  end

  it 'displays the start index of the search' do
    render

    start = json_body['start']
    expect(start).to eql(1)
  end
end
