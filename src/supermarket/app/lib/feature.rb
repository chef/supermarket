require 'redis'

class Feature
  def self.active?(*args)
    rollout.active?(*args)
  end

  def self.activate(*args)
    rollout.activate(*args)
  end

  def self.deactivate(*args)
    rollout.deactivate(*args)
  end

  def self.rollout
    @rollout ||= begin
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

  private_class_method :rollout
end
