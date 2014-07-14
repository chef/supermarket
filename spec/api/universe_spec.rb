require 'spec_helper'

describe 'GET /universe' do
  let(:redis) { create(:cookbook, name: 'redis') }
  let(:apt) { create(:cookbook, name: 'apt') }
  let(:narf) { create(:cookbook, name: 'narf') }
  let(:tarball) do
    File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz')
  end

  #
  # Given a hash of ENV variables and values, yield a block where that ENV is a
  # reality, and reset ENV after the block is called. Decidedly not threadsafe.
  #
  # @example
  #   with_env('DEBUG' => '1') { ENV['DEBUG'] } #=> '1'
  #
  # @param temporary_env [Hash] the desired ENV variables
  #
  def with_env(temporary_env = {}, &block)
    existing_env = temporary_env.map { |k, _| [k, ENV[k]] }

    temporary_env.each { |k, v| ENV[k] = v }

    block.call
  ensure
    existing_env.each { |k, v| ENV[k] = v }
  end

  before do
    redis_version1 = create(
      :cookbook_version,
      cookbook: redis,
      license: 'MIT',
      version: '1.2.0',
      tarball: tarball
    )
    redis_version2 = create(
      :cookbook_version,
      cookbook: redis,
      license: 'MIT',
      version: '1.3.0',
      tarball: tarball
    )
    apt_version = create(
      :cookbook_version,
      cookbook: apt,
      license: 'BSD',
      version: '1.1.0',
      tarball: tarball
    )
    narf_version = create(
      :cookbook_version,
      cookbook: narf,
      license: 'GPL',
      version: '1.4.0',
      tarball: tarball
    )
    create(:cookbook_dependency, cookbook_version: redis_version1, cookbook: apt, name: 'apt', version_constraint: '>= 1.0.0')
    create(:cookbook_dependency, cookbook_version: redis_version1, cookbook: narf, name: 'narf', version_constraint: '>= 1.1.0')
    create(:cookbook_dependency, cookbook_version: redis_version2, cookbook: apt, name: 'apt', version_constraint: '>= 1.0.0')
  end

  it 'returns a 200' do
    get '/universe', format: :json
    expect(response).to be_success
  end

  it 'returns http URLs by default' do
    get '/universe', format: :json

    expect(response).to be_success
    expect(json_body['redis']['1.2.0']['location_path']).to match(%r{http://.*/api/v1})
    expect(json_body['redis']['1.2.0']['download_url']).to match(%r{http://.*/api/v1/cookbooks/redis/versions/1.2.0/download})
  end

  it "returns https URLs when ENV['PROTOCOL']=https" do
    with_env('PROTOCOL' => 'https') do
      get '/universe', format: :json
    end

    expect(response).to be_success
    expect(json_body['redis']['1.2.0']['location_path']).to match(%r{https://.*/api/v1})
    expect(json_body['redis']['1.2.0']['download_url']).to match(%r{https://.*/api/v1/cookbooks/redis/versions/1.2.0/download})
  end

  it 'lists out cookbooks, their versions, and dependencies' do
    get '/universe', format: :json
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

  it 'should use supermarket location_type in the future' do
    unless Time.now < Time.at(1_412_035_199.0)
      raise 'We should implement the universe using the supermarket location_type and location_path by 2014-09-30'
    end
  end
end
