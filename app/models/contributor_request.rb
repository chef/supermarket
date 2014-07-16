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
  # @return [Boolean] whether or not acceptance succeeded
  #
  def accept
    if pending?
      transaction do
        organization.contributors.create!(user: user)

        create_contributor_request_response!(decision: 'accepted')
      end
    elsif accepted?
      true
    end
  rescue
    false
  end

  #
  # Declines the request
  #
  # @return [Boolean] whether or not declining succeeded
  #
  def decline
    if pending?
      create_contributor_request_response!(decision: 'declined')
    elsif declined?
      true
    end
  end
end
