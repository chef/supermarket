require 'spec_api_helper'

describe 'GET /api/v1/cookbooks/:cookbook/versions/:version' do

  let(:error_404) do
    {
       'error_messages' => ['Resource does not exist'],
       'error_code' => 'NOT_FOUND'
    }
  end

  context 'for a cookbook that exists' do
    before do
      create(
        :cookbook_version,
        cookbook: create(
          :cookbook,
          description: 'Sashimi that will make your heart melt',
          maintainer: 'Haru Maru',
          name: 'sashimi'
       ),
       license: 'GPLv2',
       version: '2.0.0'
      )
    end

    let(:sashimi_version_signature) do
      {
        'license' => 'GPLv2',
        'tarball_file_size' => nil,
        'version' => '2.0.0',
        'average_rating' => nil,
        'cookbook' => 'http://www.example.com/api/v1/cookbooks/sashimi',
        'file' => '/tarballs/original/missing.png'
      }
    end

    context 'for the latest version' do
      it 'returns a 200' do
        get '/api/v1/cookbooks/sashimi/versions/latest'

        expect(response.status.to_i).to eql(200)
      end

      it 'returns a version of the cookbook' do
        get '/api/v1/cookbooks/sashimi/versions/latest'

        expect(signature(json_body)).to eql(sashimi_version_signature)
      end
    end

    context 'for a version that exists' do
      it 'returns a 200' do
        get '/api/v1/cookbooks/sashimi/versions/2_0_0'

        expect(response.status.to_i).to eql(200)
      end

      it 'returns a version of the cookbook' do
        get '/api/v1/cookbooks/sashimi/versions/2_0_0'

        expect(signature(json_body)).to eql(sashimi_version_signature)
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
