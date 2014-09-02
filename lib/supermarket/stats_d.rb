module Supermarket
  module StatsD
    #
    # Increment the stat passed in if STATSD is defined.
    #
    def self.increment(stat)
      STATSD.increment(stat) if defined? STATSD
    end
  end
end
