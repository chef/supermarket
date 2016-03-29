require 'spec_helper'

describe 'POST /api/v1/cookbook_evalution_results' do
  let(:cookbook) { create(:cookbook) }
  let(:cookbook_version) { create(:cookbook_version, cookbook: cookbook) }

  it 'returns a 200' do
    post(
      '/api/v1/cookbook-versions/evaluation',
      cookbook_name: cookbook.name,
      cookbook_version: cookbook_version.version,
      foodcritic_failure: false,
      foodcritic_feedback: nil,
      fieri_key: 'YOUR_FIERI_KEY'
    )

    expect(response.status.to_i).to eql(200)
  end
end
