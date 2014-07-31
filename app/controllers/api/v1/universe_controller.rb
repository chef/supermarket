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

    SegmentIO.track_server_event('universe_api_visit', current_user)
    Universe.track_hit

    render json: MultiJson.dump(universe)
  end

  #
  # POST /universe?cookbooks=redis,postgres
  #
  # Returns a JSON response that should be compatible with the current
  # Berkshelf API response. Takes a cookbooks parameter (a comma separated list of cookbook
  # names). This will only return cookbook information related to the requested
  # cookbooks. If no cookbooks are specified, it will return all cookbooks and
  # their dependencies.
  #
  def search
    cookbooks = params.fetch(:cookbooks, nil)

    universe = Universe.generate(
      protocol: universe_cache.protocol,
      cookbooks: cookbooks
    )

    SegmentIO.track_server_event('universe_api_visit', current_user)
    Universe.track_hit

    render json: MultiJson.dump(universe)
  end

  private

  def universe_cache
    UniverseCache.new(request.protocol)
  end
end
