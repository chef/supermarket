require 'spec_helper'

describe 'GET /api/v1/search' do
  before do
    create(
      :cookbook,
      name: 'redis',
      description: 'great cookbook',
      maintainer: 'brett'
    )

    create(
      :cookbook,
      name: 'redisio',
      description: 'greater cookbook',
      maintainer: 'josh'
    )
  end

  it 'returns a 200' do
    get '/api/v1/search'

    expect(response.status.to_i).to eql(200)
  end

  it 'returns cookbooks that match the search query' do
    search_response = {
      'items' => [
        {
          'cookbook_name' => 'redis',
          'cookbook_description' => 'great cookbook',
          'cookbook' => 'http://www.example.com/api/v1/cookbooks/redis',
          'cookbook_maintainer' => 'brett'
        },
        {
          'cookbook_name' => 'redisio',
          'cookbook_description' => 'greater cookbook',
          'cookbook' => 'http://www.example.com/api/v1/cookbooks/redisio',
          'cookbook_maintainer' => 'josh'
        }
      ],
      'total' => 2,
      'start' => 0
    }

    get '/api/v1/search?q=redis'

    expect(json_body).to eql(search_response)
  end

  it 'handles the start and items params' do
    search_response = {
      'items' => [
        {
          'cookbook_name' => 'redisio',
          'cookbook_description' => 'greater cookbook',
          'cookbook' => 'http://www.example.com/api/v1/cookbooks/redisio',
          'cookbook_maintainer' => 'josh'
        }
      ],
      'total' => 1,
      'start' => 1
    }

    get '/api/v1/search?q=redis&start=1&items=1'

    expect(json_body).to eql(search_response)
  end
end
