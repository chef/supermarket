require 'spec_helper'

describe 'GET /api/v1/tools' do
  it 'returns a 200' do
    get '/api/v1/tools'

    expect(response.status.to_i).to eql(200)
  end

  context 'when there are no tools' do
    it 'returns an empty JSON template' do
      get '/api/v1/tools'

      expect(json_body['start']).to eql(0)
      expect(json_body['total']).to eql(0)
      expect(json_body['items']).to match_array([])
    end
  end

  context 'when there are tools' do
    let!(:berkshelf) { create(:tool, name: 'berkshelf') }
    let!(:knife_supermarket) { create(:tool, name: 'knife_supermarket') }

    it 'returns a JSON template with the tools' do
      get '/api/v1/tools'

      expect(json_body['start']).to eql(0)
      expect(json_body['total']).to eql(2)
      expect(json_body['items']).to match_array(
        [index_signature(berkshelf), index_signature(knife_supermarket)]
      )
    end
  end
end

def index_signature(tool)
  {
    'tool_name' => tool.name,
    'tool_type' => tool.type,
    'tool_source_url' => tool.source_url,
    'tool_description' => tool.description,
    'tool_owner' => tool.maintainer,
    'tool' => "http://www.example.com/api/v1/tools/#{tool.slug}"
  }
end
