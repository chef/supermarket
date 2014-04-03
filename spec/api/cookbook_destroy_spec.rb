require 'spec_helper'

describe 'DELETE /api/v1/cookbooks/:cookbook' do
  context 'the cookbook exists' do
    let(:cookbook_metadata_signature) do
      {
        'name' => 'redis-test',
        'maintainer' => 'Chef Software, Inc',
        'external_url' => nil,
        'description' => 'Installs/Configures redis-test',
        'average_rating' => nil,
        'category' => 'Other',
        'latest_version' => 'http://www.example.com/api/v1/cookbooks/redis-test/versions/1_0_0'
      }
    end

    before do
      share_cookbook('redis-test')
      unshare_cookbook('redis-test')
    end

    it 'returns a 200' do
      expect(response.status.to_i).to eql(200)
    end

    it 'returns the destroyed cookbook metadata' do
      expect(signature(json_body)).to eql(cookbook_metadata_signature)
    end
  end

  context "the cookbook doesn't exist" do
    before { unshare_cookbook('mamimi') }

    it 'returns a 404' do
      expect(response.status.to_i).to eql(404)
    end

    it 'returns a 404 message' do
      expect(json_body).to eql(error_404)
    end
  end
end
