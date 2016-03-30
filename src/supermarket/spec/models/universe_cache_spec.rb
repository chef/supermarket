require 'spec_helper'

describe UniverseCache do
  it 'stores cache values in a protocol-based key' do
    http_cache = UniverseCache.new('http://')
    http_cache.fetch { 'stuff' }

    https_cache = UniverseCache.new('https://')
    https_cache.fetch { 'things' }

    expect(Rails.cache.read('http-universe')).to eql('stuff')
    expect(Rails.cache.read('https-universe')).to eql('things')
  end

  it 'lazily stores values' do
    http_cache = UniverseCache.new('http://')
    http_cache.fetch { 'stuff' }
    http_cache.fetch { 'things' }

    expect(Rails.cache.read('http-universe')).to eql('stuff')
  end

  it 'can flush both caches at once' do
    http_cache = UniverseCache.new('http://')
    http_cache.fetch { 'stuff' }

    https_cache = UniverseCache.new('https://')
    https_cache.fetch { 'things' }

    UniverseCache.flush

    expect(Rails.cache.read('http-universe')).to be nil
    expect(Rails.cache.read('https-universe')).to be nil
  end
end
