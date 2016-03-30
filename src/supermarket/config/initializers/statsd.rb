if ENV['STATSD_URL'].present? && ENV['STATSD_PORT'].present?
  STATSD = Statsd.new ENV['STATSD_URL'], ENV['STATSD_PORT']
end
