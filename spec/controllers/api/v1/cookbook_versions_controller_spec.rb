require 'spec_helper'

describe Api::V1::CookbookVersionsController do
  describe '#show' do
    let!(:redis) { create(:cookbook, name: 'redis') }

    let!(:redis_0_1_2) do
      create(:cookbook_version, cookbook: redis, version: '0.1.2')
    end

    let!(:redis_1_0_0) do
      create(:cookbook_version, cookbook: redis, version: '1.0.0')
    end

    it 'responds with a 200' do
      get :show, cookbook: 'redis', version: 'latest', format: :json

      expect(response.status.to_i).to eql(200)
    end

    it 'sends the cookbook to the view' do
      get :show, cookbook: 'redis', version: 'latest', format: :json

      expect(assigns[:cookbook]).to eql(redis)
    end

    it 'sends the cookbook version to the view' do
      get :show, cookbook: 'redis', version: '1.0.0', format: :json

      expect(assigns[:cookbook_version]).to eql(redis_1_0_0)
    end

    it 'handles the latest version of a cookbook' do
      latest_version = redis.latest_cookbook_version
      get :show, cookbook: 'redis', version: 'latest', format: :json

      expect(assigns[:cookbook_version]).to eql(latest_version)
    end

    it 'handles specific versions of a cookbook' do
      get :show, cookbook: 'redis', version: '0_1_2', format: :json

      expect(assigns[:cookbook_version]).to eql(redis_0_1_2)
    end

    it '404s if a cookbook version does not exist' do
      get :show, cookbook: 'redis', version: '4_0_2', format: :json

      expect(response.status.to_i).to eql(404)
    end
  end

  describe '#download' do
    let(:cookbook) { create(:cookbook) }
    let(:version) { create(:cookbook_version, cookbook: cookbook) }

    it '302s to the cookbook version download URL' do
      get :download, cookbook: cookbook.name, version: version.to_param, format: :json

      expect(response).to redirect_to(cookbook_version_download_url(cookbook, version))
      expect(response.status.to_i).to eql(302)
    end

    it '404s when the cookbook does not exist' do
      get :download, cookbook: 'snarfle', version: '100.1.1', format: :json

      expect(response.status.to_i).to eql(404)
    end

    it '404s when the cookbook version does not exist' do
      get :download, cookbook: cookbook.name, version: '100.1.1', format: :json

      expect(response.status.to_i).to eql(404)
    end
  end
end
