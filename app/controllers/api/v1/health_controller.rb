require 'sidekiq/api'

class Api::V1::HealthController < Api::V1Controller
  #
  # GET /api/v1/health
  #
  # An overview of system health
  #
  def show
    @supermarket_health = {}
    @postgresql_health = { status: 'reachable' }
    @sidekiq_health = { status: 'reachable' }
    @redis_health = { status: 'reachable' }

    begin
      expired_ocid_tokens = Account.
        for('chef_oauth2').
          where('oauth_expires < ?', Time.now).
          count

      @supermarket_health.store(:expired_ocid_tokens, expired_ocid_tokens)

      ActiveRecord::Base.connection.query(
        "select count(*) from pg_stat_activity where waiting='t'"
      ).flatten.first.to_i.tap do |waiting_on_lock|
        @postgresql_health.store(:waiting_on_lock, waiting_on_lock)
      end

      ActiveRecord::Base.connection.query(
        'SELECT count(*) FROM pg_stat_activity'
      ).flatten.first.to_i.tap do |connections|
        @postgresql_health.store(:connections, connections)
      end
    rescue ActiveRecord::ConnectionTimeoutError
      @postgresql_health.store(:status, 'unknown')
    rescue PG::ConnectionBad
      @postgresql_health.store(:status, 'unreachable')
    end

    begin
      Sidekiq::Queue.new.tap do |queue|
        @sidekiq_health.store(:latency, queue.latency)
        @sidekiq_health.store(:queued_jobs, queue.size)
      end

      Sidekiq::ScheduledSet.new.tap do |scheduled|
        @sidekiq_health.store(:scheduled_jobs, scheduled.size)
      end

      Sidekiq::RetrySet.new.tap do |retries|
        @sidekiq_health.store(:retryable_jobs, retries.size)
      end

      Sidekiq::DeadSet.new.tap do |dead|
        @sidekiq_health.store(:dead_jobs, dead.size)
      end

      Sidekiq::Stats.new.tap do |stats|
        @sidekiq_health.store(:total_processed, stats.processed)
        @sidekiq_health.store(:total_failed, stats.failed)
      end

      Sidekiq::Workers.new.tap do |workers|
        @sidekiq_health.store(:active_workers, workers.size)
      end

      redis_info = Sidekiq.redis { |client| client.info }

      %w(uptime_in_seconds connected_clients used_memory used_memory_peak).each do |key|
        @redis_health.store(key, redis_info[key].to_i)
      end
    rescue Redis::TimeoutError
      @sidekiq_health.store(:status, 'unknown')
      @redis_health.store(:status, 'unknown')
    rescue Redis::CannotConnectError
      @sidekiq_health.store(:status, 'unreachable')
      @redis_health.store(:status, 'unreachable')
    end
  end
end
