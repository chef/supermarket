require 'spec_helper'

describe 'GET /api/v1/cookbooks/:cookbook/foodcritic' do
  let(:cookbook) do
    create(:cookbook, cookbook_versions: [
      create(
        :cookbook_version,
        foodcritic_failure: true,
        foodcritic_feedback: 'FC015: Consider converting definition to a LWRP: ./definitions/apache_conf.rb:1'
      )
    ])
  end

  let(:cookbook_foodcritic_signature) do
    {
      'failed' => cookbook.foodcritic_failure,
      'feedback' => cookbook.foodcritic_feedback
    }
  end

  it 'returns a 200' do
    get "/api/v1/cookbooks/#{cookbook.name}/foodcritic"

    expect(response.status.to_i).to eql(200)
  end

  it 'returns the foodcritic results' do
    get "/api/v1/cookbooks/#{cookbook.name}/foodcritic"

    expect(signature(json_body)).to include(cookbook_foodcritic_signature)
  end
end
