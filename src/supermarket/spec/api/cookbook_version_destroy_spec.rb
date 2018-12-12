require 'spec_helper'

describe 'DELETE /api/v1/cookbooks/:cookbook/versions/:version' do
  let(:user) { create(:user) }

  context 'from the cookbook owner' do
    before do
      share_cookbook('redis-test', user, custom_metadata: { version: '1.1.0' })
      share_cookbook('redis-test', user, custom_metadata: { version: '1.2.0' })
      unshare_cookbook_version('redis-test', '1.2.0', user)
    end

    it 'returns a 403' do
      expect(response.status.to_i).to eql(403)
    end

    it 'does not destroy the cookbook version' do
      get '/api/v1/cookbooks/redis-test/versions/1.2.0'
      expect(response.status.to_i).to eql(200)
    end

    it 'does not destroy other cookbook versions' do
      get '/api/v1/cookbooks/redis-test/versions/1.1.0'
      expect(json_body.to_s).to match(/\"1.1.0\"/)
    end
  end

  context 'from an admin' do
    let(:admin) { create(:admin) }

    before do
      share_cookbook('redis-test', user, custom_metadata: { version: '1.1.0' })
      share_cookbook('redis-test', user, custom_metadata: { version: '1.2.0' })
      unshare_cookbook_version('redis-test', '1.2.0', admin)
    end

    it 'returns a 200' do
      expect(response.status.to_i).to eql(200)
    end

    it 'returns the destroyed cookbook version metadata' do
      expect(json_body.to_s).to match(/\"1.2.0\"/)
    end

    it 'destroys the cookbook version' do
      get '/api/v1/cookbooks/redis-test/versions/1.2.0'
      expect(response.status.to_i).to eql(404)
    end

    it "doesn't destroy other cookbook versions" do
      get '/api/v1/cookbooks/redis-test/versions/1.1.0'
      expect(json_body.to_s).to match(/\"1.1.0\"/)
    end
  end

  context "the cookbook version doesn't exist" do
    before { unshare_cookbook_version('redis-test', '1_1_0', user) }

    it 'returns a 404' do
      expect(response.status.to_i).to eql(404)
    end

    it 'returns a 404 message' do
      expect(json_body).to eql(error_404)
    end
  end
end
