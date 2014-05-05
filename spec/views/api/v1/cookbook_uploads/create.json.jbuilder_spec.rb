require 'spec_helper'

describe 'api/v1/cookbook_uploads/create' do
  let(:cookbook) do
    create(
      :cookbook,
      name: 'redis',
      source_url: 'http://example.com',
      deprecated: false
    )
  end

  before do
    assign(
      :cookbook,
      cookbook
    )
  end

  it "displays the cookbook's URI" do
    render

    expect(json_body['uri']).to eql(api_v1_cookbook_url(cookbook))
  end
end
