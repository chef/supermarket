require 'spec_helper'

describe 'GET /api/v1/cookbooks/:cookbook/collaborator' do
  let(:cookbook) do
    create(:cookbook, cookbook_versions: [
      create(
        :cookbook_version,
        collaborator_failure: true,
        collaborator_feedback: 'This cookbook does not have sufficient collaborators.'
      )
    ])
  end

  let(:cookbook_collaborator_signature) do
    {
      'failed' => cookbook.collaborator_failure,
      'feedback' => cookbook.collaborator_feedback
    }
  end

  it 'returns a 200' do
    get "/api/v1/cookbooks/#{cookbook.name}/collaborator"

    expect(response.status.to_i).to eql(200)
  end

  it 'returns the collaborator results' do
    get "/api/v1/cookbooks/#{cookbook.name}/collaborator"

    expect(signature(json_body)).to include(cookbook_collaborator_signature)
  end
end
