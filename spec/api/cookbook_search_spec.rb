require 'spec_helper'

describe 'GET /api/v1/search' do
  let(:redis_test_signature) do
    {
      'cookbook_name' => 'redis-test',
      'cookbook_description' => 'Installs/Configures redis-test',
      'cookbook' => 'http://www.example.com/api/v1/cookbooks/redis-test',
      'cookbook_maintainer' => 'Chef Software, Inc'
    }
  end

  let(:redisio_test_signature) do
    {
      'cookbook_name' => 'redisio-test',
      'cookbook_description' => 'Installs/Configures redisio-test',
      'cookbook' => 'http://www.example.com/api/v1/cookbooks/redisio-test',
      'cookbook_maintainer' => 'Chef Software, Inc'
    }
  end

  before do
    share_cookbook('redis-test')
    share_cookbook('redisio-test')
  end

  it 'returns a 200' do
    get '/api/v1/search'

    expect(response.status.to_i).to eql(200)
  end

  it 'returns cookbooks that match the search query' do
    search_response = {
      'items' => [redis_test_signature, redisio_test_signature],
      'total' => 2,
      'start' => 0
    }

    get '/api/v1/search?q=redis'

    expect(json_body).to eql(search_response)
  end

  it 'handles the start and items params' do
    search_response = {
      'items' => [redisio_test_signature],
      'total' => 1,
      'start' => 1
    }

    get '/api/v1/search?q=redis&start=1&items=1'

    expect(json_body).to eql(search_response)
  end
end
