require 'spec_helper'

describe 'GET /api/v1/cookbooks/:cookbook' do
  context 'when the cookbook exists' do
    let(:user) { create(:user) }

    let(:cookbook_signature) do
      {
        'name' => 'redis-test',
        'category' => 'Other',
        'maintainer' => user.username,
        'latest_version' => 'http://www.example.com/api/v1/cookbooks/redis-test/versions/0.2.0',
        'external_url' => nil,
        'source_url' => nil,
        'issues_url' => nil,
        'versions' =>
          [
            'http://www.example.com/api/v1/cookbooks/redis-test/versions/0.2.0',
            'http://www.example.com/api/v1/cookbooks/redis-test/versions/0.1.0'
          ],
        'description' => 'Installs/Configures redis-test',
        'average_rating' => nil,
        'deprecated' => false
      }
    end

    before do
      share_cookbook('redis-test', user, custom_metadata: { version: '0.1.0' })
      share_cookbook('redis-test', user, custom_metadata: { version: '0.2.0' })

      get json_body['uri']
    end

    it 'returns a 200' do
      expect(response.status.to_i).to eql(200)
    end

    it 'returns the cookbook' do
      expect(signature(json_body)).to include(cookbook_signature)
    end
  end

  context 'when the cookbook does not exist' do
    it 'returns a 404' do
      get '/api/v1/cookbooks/mamimi'

      expect(response.status.to_i).to eql(404)
    end

    it 'returns a 404 message' do
      get '/api/v1/cookbooks/mamimi'

      expect(json_body).to eql(error_404)
    end
  end
end
