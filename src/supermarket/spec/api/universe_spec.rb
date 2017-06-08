require 'spec_helper'

describe 'GET /universe' do
  let(:redis) { create(:cookbook, name: 'redis') }
  let(:apt) { create(:cookbook, name: 'apt') }
  let(:narf) { create(:cookbook, name: 'narf') }
  let(:tarball) do
    File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz')
  end
  let!(:redis_version1) do
    create(
      :cookbook_version,
      cookbook: redis,
      license: 'MIT',
      version: '1.2.0',
      tarball: tarball
    )
  end
  let!(:redis_version2) do
    create(
      :cookbook_version,
      cookbook: redis,
      license: 'MIT',
      version: '1.3.0',
      tarball: tarball
    )
  end
  let!(:apt_version) do
    create(
      :cookbook_version,
      cookbook: apt,
      license: 'BSD',
      version: '1.1.0',
      tarball: tarball
    )
  end
  let!(:narf_version) do
    create(
      :cookbook_version,
      cookbook: narf,
      license: 'GPL',
      version: '1.4.0',
      tarball: tarball
    )
  end

  before do
    create(:cookbook_dependency, cookbook_version: redis_version1, cookbook: apt, name: 'apt', version_constraint: '>= 1.0.0')
    create(:cookbook_dependency, cookbook_version: redis_version1, cookbook: narf, name: 'narf', version_constraint: '>= 1.1.0')
    create(:cookbook_dependency, cookbook_version: redis_version2, cookbook: apt, name: 'apt', version_constraint: '>= 1.0.0')
    # this creates a self-dependency from redis to redis which must be stripped before returning
    create(:cookbook_dependency, cookbook_version: redis_version2, cookbook: redis, name: 'redis', version_constraint: '>= 1.0.0')
  end

  it 'returns a 200' do
    get '/universe', params: { format: :json }
    expect(response).to be_success
  end

  it 'returns http URLs by default' do
    get '/universe', params: { format: :json }

    expect(response).to be_success
    expect(json_body['redis']['1.2.0']['location_path']).to match(%r{http://.*/api/v1})
    expect(json_body['redis']['1.2.0']['download_url']).to match(%r{http://.*/api/v1/cookbooks/redis/versions/1.2.0/download})
  end

  it 'has an http specific cache key' do
    expect(Rails.cache).to receive(:fetch).with('http-universe')

    get '/universe', params: { format: :json }
  end

  it 'has an https specific cache key' do
    expect(Rails.cache).to receive(:fetch).with('https-universe')

    get '/universe', params: { format: :json }, headers: { 'HTTPS' => 'on' }
  end

  it "returns https URLs when ENV['PROTOCOL']=https" do
    get '/universe', params: { format: :json }, headers: { 'HTTPS' => 'on' }

    expect(response).to be_success
    expect(json_body['redis']['1.2.0']['location_path']).to match(%r{https://.*/api/v1})
    expect(json_body['redis']['1.2.0']['download_url']).to match(%r{https://.*/api/v1/cookbooks/redis/versions/1.2.0/download})
  end

  it 'lists out cookbooks, their versions, and dependencies' do
    get '/universe', params: { format: :json }
    body = json_body
    expect(body.keys).to include('redis', 'apt', 'narf')
    expect(body['redis'].keys).to include('1.2.0', '1.3.0')
    expect(body['redis']['1.2.0'].keys).to include('dependencies', 'location_type', 'location_path')
    expect(body['redis']['1.2.0']['dependencies']).to eql('apt' => '>= 1.0.0', 'narf' => '>= 1.1.0')
    expect(body['redis']['1.2.0']['location_type']).to eql('opscode')
    expect(body['redis']['1.2.0']['location_path']).to match(%r{/api/v1})
    expect(body['redis']['1.2.0']['download_url']).to match(%r{/api/v1/cookbooks/redis/versions/1.2.0/download})
    expect(body['redis']['1.3.0'].keys).to include('dependencies', 'location_type', 'location_path')
    expect(body['redis']['1.3.0']['dependencies']).to eql('apt' => '>= 1.0.0')
    expect(body['redis']['1.3.0']['location_type']).to eql('opscode')
    expect(body['redis']['1.3.0']['location_path']).to match(%r{/api/v1})
    expect(body['redis']['1.3.0']['download_url']).to match(%r{/api/v1/cookbooks/redis/versions/1.3.0/download})
    expect(body['apt']['1.1.0']['dependencies']).to eql({})
  end
end
