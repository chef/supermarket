require 'spec_helper'

describe 'DELETE /api/v1/cookbooks/:cookbook' do
  let(:user) { create(:user) }

  context 'the cookbook exists' do
    let(:cookbook_metadata_signature) do
      {
        'name' => 'redis-test',
        'maintainer' => user.username,
        'external_url' => nil,
        'source_url' => nil,
        'issues_url' => nil,
        'description' => 'Installs/Configures redis-test',
        'average_rating' => nil,
        'category' => 'Other',
        'latest_version' => 'http://www.example.com/api/v1/cookbooks/redis-test/versions/1.0.0',
        'up_for_adoption' => nil
      }
    end

    before do
      share_cookbook('redis-test', user)
      unshare_cookbook('redis-test', user)
    end

    it 'returns a 200' do
      expect(response.status.to_i).to eql(200)
    end

    it 'returns the destroyed cookbook metadata' do
      expect(signature(json_body)).to eql(cookbook_metadata_signature)
    end
  end

  context "the cookbook doesn't exist" do
    before { unshare_cookbook('mamimi', user) }

    it 'returns a 404' do
      expect(response.status.to_i).to eql(404)
    end

    it 'returns a 404 message' do
      expect(json_body).to eql(error_404)
    end
  end
end
