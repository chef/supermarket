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
    'pending' == self.state
  end

  #
  # Has this request been accepted?
  #
  # @return [Boolean]
  #
  def accepted?
    'accepted' == self.state
  end

  #
  # Has this request been declined?
  #
  # @return [Boolean]
  #
  def declined?
    'declined' == self.state
  end

  #
  # Accepts the request, adding the requestor to the requested organization,
  # and updating the status of this request.
  #
  # @return [Boolean] whether or not acceptance succeeded
  #
  def accept
    transaction do
      self.organization.contributors.create!(
        user: self.user
      )

      self.update_attributes!(state: 'accepted')
    end
  rescue
    false
  else
    true
  end
end
