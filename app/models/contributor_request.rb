class ContributorRequest < ActiveRecord::Base
  belongs_to :organization
  belongs_to :ccla_signature
  belongs_to :user

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
    'pending' == state
  end

  #
  # Has this request been accepted?
  #
  # @return [Boolean]
  #
  def accepted?
    'accepted' == state
  end

  #
  # Has this request been declined?
  #
  # @return [Boolean]
  #
  def declined?
    'declined' == state
  end

  #
  # Accepts the request, adding the requestor to the requested organization,
  # and updating the status of this request.
  #
  # @return [Boolean] whether or not acceptance succeeded
  #
  def accept
    if !declined?
      transaction do
        organization.contributors.where(user: user).first_or_create!

        update_attributes!(state: 'accepted')
      end
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
    if !accepted?
      update_attributes(state: 'declined')
    end
  end
end
