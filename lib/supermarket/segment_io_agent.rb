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
    # configuration does not specify +SEGMENT_IO_WRITE_KEY+, this agent will not
    # be enabled.
    #
    # @param config [Hash] the agent caller's configuration
    #
    def initialize(config)
      @enabled = config['SEGMENT_IO_WRITE_KEY'].to_s.size > 0
      @last_event = {}

      if enabled?
        require 'analytics-ruby'

        @segment_io = AnalyticsRuby.tap do |segment_io|
          segment_io.init(secret: config['SEGMENT_IO_WRITE_KEY'])
        end
      end
    end

    #
    # @!attribute [r] enabled
    #   @return [Boolean] whether or not the agent is enabled
    #
    attr_reader :enabled

    #
    # @!attribute [r] last_event
    #   @return [Hash] the most recent event tracked
    #
    attr_reader :last_event

    alias_method :enabled?, :enabled

    #
    # Tracks an event with the given +name+ and +properties+ as having been
    # performed by the "web_server" user.
    #
    # @param name [String] the name of the event
    # @param properties [Hash] the properties, if any, associated with the event
    #
    def track_server_event(name, properties = {})
      @last_event = { name: name, properties: properties }

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
