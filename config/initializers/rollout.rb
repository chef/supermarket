def Object.const_missing(const)
  if const == :ROLLOUT
    require 'redis'

    redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379/0/supermarket'

    redis = Redis.new(url: redis_url)
    Object.const_set('ROLLOUT', Rollout.new(redis))

    features = ENV['FEATURES'].to_s.split(',').map {|f| f.strip }

    #
    # Features that are defined in rollout but are no longer defined
    # in ENV['FEATURES'] need to be deactivated.
    #
    (ROLLOUT.features - features).each do |feature|
      ROLLOUT.deactivate(feature)
    end

    #
    # Features that are defined in ENV['FEATURES'] but are
    # not defined in rollout need to be activated.
    #
    (features - ROLLOUT.features).each do |feature|
      ROLLOUT.activate(feature)
    end

    ROLLOUT
  else
    super
  end
end
