if Supermarket::Config.statsd['host'].present? && Supermarket::Config.statsd['port'].present?
  STATSD = Statsd.new(Supermarket::Config.statsd['host'], Supermarket::Config.statsd['port'])

  if Supermarket::Config.statsd['namespace'].present?
    STATSD.namespace = Supermarket::Config.statsd['namespace']
  end
end
