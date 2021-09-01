# frozen_string_literal: true

module Supermarket
  class Health
    #
    # This class encapsulates the logic used to perform health checks on the
    # system. The methods in here are mostly private and exist solely for their
    # side-effects, not their return values.
    #

    REACHABLE = "reachable"
    UNKNOWN = "unknown"
    UNREACHABLE = "unreachable"
    ALL_FEATURES = %w{tools fieri announcement github no_crawl}.freeze

    attr_reader :status, :supermarket, :postgresql, :sidekiq, :redis, :features

    def initialize
      @status = nil
      @supermarket = {}
      @features = {}
      @postgresql = { status: REACHABLE }
      @sidekiq = { status: REACHABLE }
      @redis = { status: REACHABLE }
    end

    #
    # Do a general health check.
    #
    def check
      expired_ocid_tokens
      waiting_on_lock
      connections
      sidekiq_health
      redis_health
      check_features
      overall
    end

    private

    #
    # Which features are enabled?
    #
    def check_features
      current_features = ENV["FEATURES"].split(",")

      @features = ALL_FEATURES.reduce({}) do |result, feature|
        result[feature] = current_features.include?(feature)
        result
      end
    end

    #
    # Check to see if there are expired oc-id tokens
    #
    def expired_ocid_tokens
      postgres_health_metric do
        @supermarket[:expired_ocid_tokens] = Account
          .for("chef_oauth2")
          .where("oauth_expires < ?", Time.current)
          .count
      end
    end

    #
    # Check to see if any Postgres connections are waiting on a lock
    #
    def waiting_on_lock
      wait_query = if ActiveRecord::Base.connection.postgresql_version < 90600
                     "select count(*) from pg_stat_activity where waiting='t'"
                   else
                     "select count(*) from pg_stat_activity WHERE wait_event is not NULL"
                   end

      postgres_health_metric do
        ActiveRecord::Base.connection
          .query(wait_query)
          .flatten
          .first
          .to_i
          .tap do |waiting_on_lock|
            @postgresql[:waiting_on_lock] = waiting_on_lock
          end
      end
    end

    #
    # Check to see how many active Postgres connections there are
    #
    def connections
      postgres_health_metric do
        ActiveRecord::Base.connection.query(
          "SELECT count(*) FROM pg_stat_activity"
        ).flatten.first.to_i.tap do |connections|
          @postgresql[:connections] = connections
        end
      end
    end

    #
    # Gather some various Sidekiq health metrics
    #
    def sidekiq_health
      redis_health_metric do
        Sidekiq::Queue.new.tap do |queue|
          @sidekiq[:latency] = queue.latency
          @sidekiq[:queued_jobs] = queue.size
        end

        Sidekiq::ScheduledSet.new.tap do |scheduled|
          @sidekiq[:scheduled_jobs] = scheduled.size
        end

        Sidekiq::RetrySet.new.tap do |retries|
          @sidekiq[:retryable_jobs] = retries.size
        end

        Sidekiq::DeadSet.new.tap do |dead|
          @sidekiq[:dead_jobs] = dead.size
        end

        Sidekiq::Stats.new.tap do |stats|
          @sidekiq[:total_processed] = stats.processed
          @sidekiq[:total_failed] = stats.failed
        end

        Sidekiq::Workers.new.tap do |workers|
          @sidekiq[:active_workers] = workers.size
        end
      end
    end

    #
    # Gather some various Redis health metrics
    #
    def redis_health
      redis_health_metric do
        redis_info = Sidekiq.redis(&:info)

        %w{uptime_in_seconds connected_clients used_memory used_memory_peak}.each do |key|
          @redis.store(key, redis_info.fetch(key, -1).to_i)
        end
      end
    end

    #
    # What is the overall system status
    #
    def overall
      @status = if @sidekiq[:status] == REACHABLE &&
                   @postgresql[:status] == REACHABLE &&
                   @redis[:status] == REACHABLE
                  "ok"
                else
                  "not ok"
                end
    end

    #
    # Perform an action against the Postgres database and if it fails, mark the
    # appropriate status.
    #
    def postgres_health_metric
      yield
    rescue ActiveRecord::ConnectionTimeoutError
      @postgresql[:status] = UNKNOWN
    rescue PG::ConnectionBad
      @postgresql[:status] = UNREACHABLE
    end

    #
    # Perform an action against the Postgres database and if it fails, mark the
    # appropriate status.
    #
    def redis_health_metric
      yield
    rescue Redis::TimeoutError
      @sidekiq[:status] = UNKNOWN
      @redis[:status] = UNKNOWN
    rescue Redis::CannotConnectError
      @sidekiq[:status] = UNREACHABLE
      @redis[:status] = UNREACHABLE
    end
  end
end
