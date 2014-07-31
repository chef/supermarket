class Api::V1::UniverseController < Api::V1Controller
  #
  # GET /universe
  #
  # Returns a JSON response that should be compatible with the current
  # Berkshelf API response. It will have cookbooks, all their versions, and
  # dependency/platform information.
  #
  # Takes an optional cookbooks parameter (a comma separated list of cookbook
  # names). This will only return cookbook information related to the requested
  # cookbooks.
  #
  # @example
  #
  #   GET /universe
  #   GET /universe?cookbooks=redis,postgres
  #
  def index
    cookbooks = params.fetch(:cookbooks, nil)

    universe = universe_cache.fetch do
      Universe.generate(protocol: universe_cache.protocol, cookbooks: cookbooks)
    end

    SegmentIO.track_server_event('universe_api_visit', current_user)
    Universe.track_hit

    render json: MultiJson.dump(universe)
  end

  private

  def universe_cache
    UniverseCache.new(request.protocol)
  end
end
