require 'spec_helper'

describe 'GET /api/v1/tools/:tool' do
  context 'when the tool exists' do
    let(:tool) { create(:tool) }

    let(:tool_signature) do
      {
        'name' => tool.name,
        'slug' => tool.slug,
        'type' => tool.type,
        'source_url' => tool.source_url,
        'description' => tool.description,
        'instructions' => tool.instructions,
        'owner' => tool.maintainer
      }
    end

    it 'returns a 200' do
      get "/api/v1/tools/#{tool.slug}"

      expect(response.status.to_i).to eql(200)
    end

    it 'returns the tool' do
      get "/api/v1/tools/#{tool.slug}"

      expect(signature(json_body)).to include(tool_signature)
    end
  end

  context 'when the tool does not exist' do
    it 'returns a 404' do
      get '/api/v1/tools/trololol'

      expect(response.status.to_i).to eql(404)
    end

    it 'returns a 404 message' do
      get '/api/v1/tools/trololol'

      expect(json_body).to eql(error_404)
    end
  end
end
