require 'spec_helper'

describe 'GET /api/v1/cookbooks' do
  it 'returns a 200' do
    get '/api/v1/cookbooks'

    expect(response.status.to_i).to eql(200)
  end

  context 'when there are no cookbooks' do
    it 'returns an empty JSON template' do
      get '/api/v1/cookbooks'

      expect(json_body['start']).to eql(0)
      expect(json_body['total']).to eql(0)
      expect(json_body['items']).to match_array([])
    end
  end

  context 'when there are cookbooks' do
    let(:redis_test_signature) do
      {
        'cookbook_name' => 'redis-test',
        'cookbook_maintainer' => user.username,
        'cookbook_description' => 'Installs/Configures redis-test',
        'cookbook' => 'http://www.example.com/api/v1/cookbooks/redis-test'
      }
    end

    let(:redisio_test_signature) do
      {
        'cookbook_name' => 'redisio-test',
        'cookbook_maintainer' => user.username,
        'cookbook_description' => 'Installs/Configures redisio-test',
        'cookbook' => 'http://www.example.com/api/v1/cookbooks/redisio-test'
      }
    end

    let(:user) { create(:user) }

    before do
      share_cookbook('redis-test', user)
      share_cookbook('redisio-test', user)
    end

    it 'returns a JSON template with the cookbooks' do
      get '/api/v1/cookbooks'

      expect(json_body['start']).to eql(0)
      expect(json_body['total']).to eql(2)
      expect(json_body['items']).
        to match_array([redis_test_signature, redisio_test_signature])
    end
  end
end
