# frozen_string_literal: true
class ContributorRequestResponse < ActiveRecord::Base
  ACCEPTED = 'accepted'.freeze unless defined? ACCEPTED
  DECLINED = 'declined'.freeze unless defined? DECLINED

  validates :contributor_request_id, uniqueness: true, presence: true
  validates :decision, inclusion: { in: [ACCEPTED, DECLINED] }

  #
  # Creates a new +ContributorRequestResponse+ record for the given
  # +contributor_request+ with +decision+ set to 'accepted'
  #
  # @param contributor_request [ContributorRequest]
  #
  # @return [ContributorRequestResponse]
  #
  def self.accept!(contributor_request)
    create!(
      contributor_request_id: contributor_request.id,
      decision: ACCEPTED
    )
  end

  #
  # Creates a new +ContributorRequestResponse+ record for the given
  # +contributor_request+ with +decision+ set to 'declined'
  #
  # @param contributor_request [ContributorRequest]
  #
  # @return [ContributorRequestResponse]
  #
  def self.decline!(contributor_request)
    create!(
      contributor_request_id: contributor_request.id,
      decision: DECLINED
    )
  end

  #
  # Determines if the response accepted the requestor as a contributor
  #
  # @return [Boolean]
  #
  def affirmative?
    ACCEPTED == decision
  end

  #
  # Determines if the response declined the requestor as a contributor
  #
  # @return [Boolean]
  #
  def negative?
    DECLINED == decision
  end
end
