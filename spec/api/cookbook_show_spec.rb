require 'spec_helper'

describe 'GET /api/v1/cookbooks/:cookbook' do

  context 'when the cookbook exists' do

    let(:sashimi_signature) do
      {
        'name' => 'apache',
        'category' => 'web servers',
        'maintainer' => 'jtimberman',
        'latest_version' => 'http://www.example.com/api/v1/cookbooks/apache/versions/2_0',
        'external_url' => nil,
        'versions' =>
          [
            'http://www.example.com/api/v1/cookbooks/apache/versions/2_0',
            'http://www.example.com/api/v1/cookbooks/apache/versions/1_0'
          ],
        'description' => 'installs apache.',
        'average_rating' => nil,
        'deprecated' => false
      }
    end

    let!(:cookbook) do
      create(
        :cookbook,
        name: 'apache',
        category: 'web servers',
        maintainer: 'jtimberman',
        external_url: nil,
        description: 'installs apache.'
      )
    end

    before do
      publish_version(cookbook, '1.0')
      publish_version(cookbook, '2.0')
    end

    it 'returns a 200' do
      get '/api/v1/cookbooks/apache'

      expect(response.status.to_i).to eql(200)
    end

    it 'returns the cookbook' do
      get '/api/v1/cookbooks/apache'

      expect(signature(json_body)).to eql(sashimi_signature)
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
