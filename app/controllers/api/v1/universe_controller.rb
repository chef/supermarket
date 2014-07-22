class Api::V1::UniverseController < Api::V1Controller
  #
  # GET /universe
  #
  # Returns a JSON response that should be compatible with the current
  # Berkshelf API response. It will have cookbooks, all their versions, and
  # dependency/platform information.
  #
  def index
    universe = Rails.cache.fetch(cache_key) do
      Universe.generate(protocol: protocol)
    end

    SegmentIO.track_server_event('universe_api_visit', current_user)
    Universe.track_hit

    render json: MultiJson.dump(universe)
  end

  private

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
    @protocol ||= ENV.fetch('PROTOCOL', 'http')
  end
end
