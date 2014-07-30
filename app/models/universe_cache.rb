class UniverseCache
  #
  # Flush both the http cache and the https cache
  #
  def self.flush
    ['http://', 'https://'].each do |protocol|
      new(protocol).delete
    end
  end

  def initialize(protocol)
    @raw_protocol = protocol
  end

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
  # Returns the protocol in a way appropriate for cache key usage, e.g. for
  # a protocol string of "http://", this method will return "http"
  #
  # @return [String] the protocol string
  #
  def protocol
    @protocol ||= @raw_protocol[0..-4]
  end
end
