class Api::V1::UniverseController < Api::V1Controller
  CACHE_KEY = 'universe'

  #
  # GET /universe
  #
  # Returns a JSON response that should be compatible with the current
  # Berkshelf API response. It will have cookbooks, all their versions, and
  # dependency/platform information.
  #
  def index
    universe = Rails.cache.fetch(CACHE_KEY) do
      Universe.generate(protocol: ENV.fetch('PROTOCOL', 'http'))
    end

    SegmentIO.track_server_event('universe_api_visit', current_user)
    Universe.track_hit

    render json: MultiJson.dump(universe)
  end
end
