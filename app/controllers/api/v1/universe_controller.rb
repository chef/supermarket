class Api::V1::UniverseController < Api::V1Controller
  #
  # GET /universe
  #
  # Returns a JSON response that should be compatible with the current
  # Berkshelf API response. It will have cookbooks, all their versions, and
  # dependency/platform information.
  #
  def index
    universe = universe_cache.fetch do
      Universe.generate(protocol: universe_cache.protocol)
    end

    Universe.track_hit

    render json: MultiJson.dump(universe)
  end

  private

  def universe_cache
    UniverseCache.new(request.protocol)
  end
end
