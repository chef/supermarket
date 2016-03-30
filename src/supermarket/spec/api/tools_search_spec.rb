require 'spec_helper'

describe 'GET /api/v1/tools/search' do
  let!(:berkshelf) { create(:tool, name: 'berkshelf') }
  let!(:berkshelf_2) { create(:tool, name: 'berkshelf-2') }

  it 'returns a 200' do
    get '/api/v1/tools-search'

    expect(response.status.to_i).to eql(200)
  end

  it 'returns tools that match the search query' do
    search_response = {
      'items' => [search_signature(berkshelf), search_signature(berkshelf_2)],
      'total' => 2,
      'start' => 0
    }

    get '/api/v1/tools-search?q=berkshelf'

    expect(json_body).to eql(search_response)
  end

  it 'handles the start and items params' do
    search_response = {
      'items' => [search_signature(berkshelf_2)],
      'total' => 1,
      'start' => 1
    }

    get '/api/v1/tools-search?q=berkshelf&start=1&items=1'

    expect(json_body).to eql(search_response)
  end
end

def search_signature(tool)
  {
    'tool_name' => tool.name,
    'tool_type' => tool.type,
    'tool_source_url' => tool.source_url,
    'tool_description' => tool.description,
    'tool_owner' => tool.maintainer,
    'tool' => "http://www.example.com/api/v1/tools/#{tool.slug}"
  }
end
