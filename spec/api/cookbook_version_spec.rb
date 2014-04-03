require 'spec_helper'

describe 'GET /api/v1/cookbooks/:cookbook/versions/:version' do
  context 'for a cookbook that exists' do
    before do
      share_cookbook('redis-test', custom_metadata: { version: '0.1.0' })
      share_cookbook('redis-test', custom_metadata: { version: '0.2.0' })
      get json_body['uri']
    end

    context 'for the latest version' do
      let(:cookbook_version_signature) do
        {
          'license' => 'MIT',
          'version' => '0.2.0',
          'average_rating' => nil,
          'cookbook' => 'http://www.example.com/api/v1/cookbooks/redis-test'
        }
      end

      it 'returns a 200' do
        get '/api/v1/cookbooks/redis-test/versions/latest'

        expect(response.status.to_i).to eql(200)
      end

      it 'returns a version of the cookbook' do
        get '/api/v1/cookbooks/redis-test/versions/latest'

        expect(signature(json_body)).to eql(cookbook_version_signature)
      end
    end

    context 'for a version that exists' do
      let(:cookbook_version_signature) do
        {
          'license' => 'MIT',
          'version' => '0.1.0',
          'average_rating' => nil,
          'cookbook' => 'http://www.example.com/api/v1/cookbooks/redis-test'
        }
      end

      it 'returns a 200' do
        get json_body['versions'].find { |v| v =~ /0_1_0/ }

        expect(response.status.to_i).to eql(200)
      end

      it 'returns a version of the cookbook' do
        get json_body['versions'].find { |v| v =~ /0_1_0/ }

        expect(signature(json_body)).to eql(cookbook_version_signature)
      end
    end

    context 'for a version that does not exist' do
      it 'returns a 404' do
        get '/api/v1/cookbooks/sashimi/versions/2_1_0'

        expect(response.status.to_i).to eql(404)
      end

      it 'returns a 404 message' do
        get '/api/v1/cookbooks/sashimi/versions/2_1_0'

        expect(json_body).to eql(error_404)
      end
    end
  end

  context 'for a cookbook that does not exist' do
    it 'returns a 404' do
      get '/api/v1/cookbooks/mamimi/versions/1_3_0'

      expect(response.status.to_i).to eql(404)
    end

    it 'returns a 404 message' do
      get '/api/v1/cookbooks/mamimi/versions/1_333'

      expect(json_body).to eql(error_404)
    end
  end
end
