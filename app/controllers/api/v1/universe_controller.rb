class Api::V1::UniverseController < Api::V1Controller
  #
  # GET /universe
  #
  # Returns a JSON response that should be compatible with the current
  # Berkshelf API response. It will have cookbooks, all their versions, and
  # dependency/platform information.
  #
  def index
    universe = UniverseCache.fetch do
      Universe.generate(protocol: UniverseCache.protocol)
    end

    SegmentIO.track_server_event('universe_api_visit', current_user)
    Universe.track_hit

    render json: MultiJson.dump(universe)
  end
end
