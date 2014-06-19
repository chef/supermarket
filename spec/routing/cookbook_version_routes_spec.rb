require 'spec_helper'

describe 'cookbook version routes' do
  context 'API' do
    context '#show' do
      it 'can route using underscores' do
        expect(get: '/api/v1/cookbooks/redis/versions/1_0_0', format: :json).to route_to(controller: 'api/v1/cookbook_versions', action: 'show', format: :json, cookbook: 'redis', version: '1_0_0')
      end

      it 'can route using periods' do
        expect(get: '/api/v1/cookbooks/redis/versions/1.0.0', format: :json).to route_to(controller: 'api/v1/cookbook_versions', action: 'show', format: :json, cookbook: 'redis', version: '1.0.0')
      end

      it 'can route using "latest"' do
        expect(get: '/api/v1/cookbooks/redis/versions/latest', format: :json).to route_to(controller: 'api/v1/cookbook_versions', action: 'show', format: :json, cookbook: 'redis', version: 'latest')
      end
    end

    context '#download' do
      it 'can route using underscores' do
        expect(get: '/api/v1/cookbooks/redis/versions/1_0_0/download', format: :json).to route_to(controller: 'api/v1/cookbook_versions', action: 'download', format: :json, cookbook: 'redis', version: '1_0_0')
      end

      it 'can route using periods' do
        expect(get: '/api/v1/cookbooks/redis/versions/1.0.0/download', format: :json).to route_to(controller: 'api/v1/cookbook_versions', action: 'download', format: :json, cookbook: 'redis', version: '1.0.0')
      end

      it 'can route using "latest"' do
        expect(get: '/api/v1/cookbooks/redis/versions/latest/download', format: :json).to route_to(controller: 'api/v1/cookbook_versions', action: 'download', format: :json, cookbook: 'redis', version: 'latest')
      end
    end
  end

  context 'public website' do
    context '#show' do
      it 'can route using underscores' do
        expect(get: '/cookbooks/redis/versions/1_0_0').to route_to(controller: 'cookbook_versions', action: 'show', cookbook_id: 'redis', version: '1_0_0')
      end

      it 'can route using periods' do
        expect(get: '/cookbooks/redis/versions/1.0.0').to route_to(controller: 'cookbook_versions', action: 'show', cookbook_id: 'redis', version: '1.0.0')
      end

      it 'can route using "latest"' do
        expect(get: '/cookbooks/redis/versions/latest').to route_to(controller: 'cookbook_versions', action: 'show', cookbook_id: 'redis', version: 'latest')
      end
    end

    context '#download' do
      it 'can route using underscores' do
        expect(get: '/cookbooks/redis/versions/1_0_0/download').to route_to(controller: 'cookbook_versions', action: 'download', cookbook_id: 'redis', version: '1_0_0')
      end

      it 'can route using periods' do
        expect(get: '/cookbooks/redis/versions/1.0.0/download').to route_to(controller: 'cookbook_versions', action: 'download', cookbook_id: 'redis', version: '1.0.0')
      end

      it 'can route using "latest"' do
        expect(get: '/cookbooks/redis/versions/latest/download').to route_to(controller: 'cookbook_versions', action: 'download', cookbook_id: 'redis', version: 'latest')
      end
    end
  end
end
