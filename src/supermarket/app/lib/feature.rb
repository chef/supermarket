require 'redis'

module Feature
  extend Forwardable

  # feature flag methods delegated to the adapter to wrap the flip/check implementation
  # if more methods from the adapter need to be exposed, add them to the list of delegated
  # methods here
  module_function(*def_delegators('Feature.adapter', :active?, :activate, :deactivate))

  @rollout = nil

  def self.adapter
    return @rollout if @rollout

    redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379/0/supermarket'
    redis = Redis.new(url: redis_url)
    @rollout = Rollout.new(redis)

    features = ENV['FEATURES'].to_s.split(',').map(&:strip)

    #
    # Features that are defined in rollout but are no longer defined
    # in ENV['FEATURES'] need to be deactivated.
    #
    (@rollout.features - features).each do |feature|
      @rollout.deactivate(feature)
    end

    #
    # Features that are defined in ENV['FEATURES'] but are
    # not defined in rollout need to be activated.
    #
    (features - @rollout.features).each do |feature|
      @rollout.activate(feature)
    end

    @rollout
  end
end
