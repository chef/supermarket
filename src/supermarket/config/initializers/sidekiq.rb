redis_for_job_queue = ENV['REDIS_JOBQ_URL'].presence ||
                      ENV['REDIS_URL'].presence ||
                      'redis://localhost:6379/0/supermarket'

Sidekiq.configure_server do |config|
  config.redis = { url: redis_for_job_queue }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_for_job_queue }
end
