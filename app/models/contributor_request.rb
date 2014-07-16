class ContributorRequest < ActiveRecord::Base
  belongs_to :organization
  belongs_to :ccla_signature
  belongs_to :user
  has_one :contributor_request_response

  #
  # The users who preside over this request
  #
  def presiding_admins
    organization.admins.includes(:user).map(&:user)
  end

  #
  # Is this request pending approval or denial?
  #
  # @return [Boolean]
  #
  def pending?
    contributor_request_response.blank?
  end

  #
  # Has this request been accepted?
  #
  # @return [Boolean]
  #
  def accepted?
    contributor_request_response.try(:decision) == 'accepted'
  end

  #
  # Has this request been declined?
  #
  # @return [Boolean]
  #
  def declined?
    contributor_request_response.try(:decision) == 'declined'
  end

  #
  # Accepts the request, adding the requestor to the requested organization,
  # and updating the status of this request.
  #
  # @yield [ContributorRequestTransition] the resulting transition
  # @return [ContributorRequestTransition] the resulting transition
  #
  def accept
    transaction do
      organization.contributors.create!(user: user)

      ContributorRequestResponse.create!(
        contributor_request_id: id,
        decision: 'accepted'
      )
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    ContributorRequestTransition.accept(self, false).tap do |transition|
      yield transition if block_given?
    end
  else
    ContributorRequestTransition.accept(self, true).tap do |transition|
      yield transition if block_given?
    end
  end

  #
  # Declines the request
  #
  # @yield [ContributorRequestTransition] the resulting transition
  # @return [ContributorRequestTransition] the resulting transition
  #
  def decline
    ContributorRequestResponse.create!(
      contributor_request_id: id,
      decision: 'declined'
    )
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    ContributorRequestTransition.decline(self, false).tap do |transition|
      yield transition if block_given?
    end
  else
    ContributorRequestTransition.decline(self, true).tap do |transition|
      yield transition if block_given?
    end
  end
end
