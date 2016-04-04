require 'sidekiq/api'

class Api::V1::HealthController < Api::V1Controller
  #
  # GET /api/v1/health
  #
  # An overview of system health. Its HTTP status only reflects the API's
  # ability to report status. In particular, this endpoint will return a status
  # of 200 even if Redis and Postgres are both hosed. The response body
  # contains information with regard to the health of individual system
  # components.
  #
  def show
    @health = Supermarket::Health.new
    @health.check
  end
end
