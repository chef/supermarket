redis_for_job_queue = ENV["REDIS_JOBQ_URL"].presence ||
                      ENV["REDIS_URL"].presence ||
                      "redis://localhost:6379/0/supermarket"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_for_job_queue }

  # make Sidekiq load the schedule, because Redis
  # probably reachable at this point
  Sidekiq::Cron::Job.load_from_hash(
    "Daily refresh of the sitemap" => {
      class: "SitemapRefreshWorker",
      cron: "@daily",
    },
    "Schedule refresh of expiring tokens" => {
      class: "OauthTokenRefreshScheduleWorker",
      cron: "*/5 * * * *",
    }
  )
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_for_job_queue }
end

Sidekiq::Extensions.enable_delay!
