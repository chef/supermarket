require_dependency 'fieri/application_controller'

module Fieri
  class StatusController < ApplicationController
    require 'sidekiq/api'

    REACHABLE = 'REACHABLE'.freeze
    UNKNOWN = 'UNKNOWN'.freeze
    UNREACHABLE = 'UNREACHABLE'.freeze

    def show
      redis_health = { status: REACHABLE }
      sidekiq_health = { status: REACHABLE }

      begin
        Sidekiq::Queue.new.tap do |queue|
          sidekiq_health.store(:latency, queue.latency)
          sidekiq_health.store(:queued_jobs, queue.size)
        end

        sidekiq_health.store(:active_workers, Sidekiq::Workers.new.size)
        sidekiq_health.store(:dead_jobs, Sidekiq::DeadSet.new.size)
        sidekiq_health.store(:retryable_jobs, Sidekiq::RetrySet.new.size)

        Sidekiq::Stats.new.tap do |stats|
          sidekiq_health.store(:total_processed, stats.processed)
          sidekiq_health.store(:total_failed, stats.failed)
        end

        redis_info = Sidekiq.redis(&:info)

        %w(uptime_in_seconds connected_clients used_memory used_memory_peak).each do |key|
          redis_health.store(key, redis_info.fetch(key, -1).to_i)
        end
      rescue Redis::TimeoutError
        sidekiq_health.store(:status, UNKNOWN)
        redis_health.store(:status, UNKNOWN)
      rescue Redis::CannotConnectError
        sidekiq_health.store(:status, UNREACHABLE)
        redis_health.store(:status, UNREACHABLE)
      end

      status = if redis_health.fetch(:status) == 'REACHABLE' &&
                  sidekiq_health.fetch(:status) == 'REACHABLE'
                 'ok'
               else
                 'not ok'
               end

      response = {
        'status' => status,
        'sidekiq' => sidekiq_health,
        'redis' => redis_health
      }.to_json

      render json: response
    end
  end
end
