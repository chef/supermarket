module Supermarket
  #
  # Wraps Segment.io's AnalyticsRuby library in a Supermarket-specific way.
  # Instances of this class are instantiated on app startup and typically
  # exposed as a singleton.
  #
  # @example
  #   SegmentIO = SegmentIoAgent.new(some_configuration_hash_like_thing)
  #
  class SegmentIoAgent
    #
    # Create a new +SegmentIoAgent+ with the given configuration. If the
    # configuration does not specify +segment_io_write_key+, this agent will not
    # be enabled.
    #
    # @param config [Supermarket::Config] the agent caller's configuration
    #
    def initialize(config)
      @enabled = config.segment_io_write_key.to_s.size > 0

      if enabled?
        require 'analytics-ruby'

        @segment_io = AnalyticsRuby.tap do |segment_io|
          segment_io.init(secret: config.segment_io_write_key)
        end
      end
    end

    #
    # @!attribute [r] enabled
    #   @return [Boolean] whether or not the agent is enabled
    #
    attr_reader :enabled

    alias_method :enabled?, :enabled

    #
    # Tracks an event with the given +name+ and +properties+ as having been
    # performed by the "web_server" user.
    #
    # @param name [String] the name of the event
    # @param properties [Hash] the properties, if any, associated with the event
    #
    def track_server_event(name, properties = {})
      if enabled?
        @segment_io.track(
          user_id: 'web_server',
          event: name,
          properties: properties
        )
      end
    end
  end
end
