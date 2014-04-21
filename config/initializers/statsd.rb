if [ENV['STATSD_HOST'], ENV['STATSD_PORT']].all?(&:present?)
  STATSD = Statsd.new(ENV['STATSD_HOST'], ENV['STATSD_PORT'])

  if ENV['STATSD_NAMESPACE'].present?
    STATSD.namespace = ENV['STATSD_NAMESPACE']
  end
end
