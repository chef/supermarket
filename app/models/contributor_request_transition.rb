#
# Represents the result of responding to a +ContributorRequest+. Intended to be
# instantiated from +accept+ and +decline+ methods on +ContributorRequest+.
#
class ContributorRequestTransition
  #
  # @!attribute [r] :authoritative?
  #   @return [Boolean] Whether or not the transition is considered
  #     authoritative. That is, was the transition the first response to the
  #     request?
  #
  attr_reader :authoritative
  alias_method :authoritative?, :authoritative

  #
  # Constructs a transition which represents an attempt to accept the given
  # +contributor_request+
  #
  # @param contributor_request [ContributorRequest]
  # @param authoritative [Boolean] whether or not the transition should be
  #   considered authoritative
  #
  def self.accept(contributor_request, authoritative)
    new(contributor_request, authoritative, :accept)
  end

  #
  # Constructs a transition which represents an attempt to decline the given
  # +contributor_request+
  #
  # @param contributor_request [ContributorRequest]
  # @param authoritative [Boolean] whether or not the transition should be
  #   considered authoritative
  #
  def self.decline(contributor_request, authoritative)
    new(contributor_request, authoritative, :decline)
  end

  def initialize(contributor_request, authoritative, action)
    @contributor_request = contributor_request
    @authoritative = authoritative
    @action = action
  end

  #
  # Determines if the request transitioned as intended. If the transition is
  # considered either authoritative or consistent, the transition succeeded.
  #
  # @return [Boolean]
  #
  def successful?
    authoritative? || consistent?
  end

  private

  #
  # Is the state of the request consistent with the desired action?
  #
  # @return [Boolean]
  #
  def consistent?
    (@action == :accept && @contributor_request.accepted?) ||
      (@action == :decline && @contributor_request.declined?)
  end
end
