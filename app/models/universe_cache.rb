module UniverseCache
  module_function

  #
  # Fetch something from the cache
  #
  # @param [Proc] the block to execute and store on a cache miss
  #
  # @return [Hash] the cache results
  #
  def fetch(&block)
    Rails.cache.fetch(cache_key, &block)
  end

  #
  # Delete the cache
  #
  def delete
    Rails.cache.delete(cache_key)
  end

  #
  # Returns the cache key to use for /universe, which varies based on the
  # protocol
  #
  # @return [String] the cache key
  #
  def cache_key
    "#{protocol}-universe"
  end

  #
  # Returns the protocol to use, based on the environment variables
  #
  # @return [String] HTTP protocol to use
  #
  def protocol
    ENV.fetch('PROTOCOL', 'http')
  end
end
