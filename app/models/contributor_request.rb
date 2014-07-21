class ContributorRequest < ActiveRecord::Base
  belongs_to :organization
  belongs_to :ccla_signature
  belongs_to :user
  has_one :contributor_request_response

  validates :organization, presence: true
  validates :ccla_signature, presence: true
  validates :user, presence: true

  #
  # The users who preside over this request
  #
  # @return [Array<User>]
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
    contributor_request_response.try(:affirmative?)
  end

  #
  # Has this request been declined?
  #
  # @return [Boolean]
  #
  def declined?
    contributor_request_response.try(:negative?)
  end

  #
  # Accepts the request, adding the requestor to the requested organization,
  # and updating the status of this request.
  #
  # @yield if this is the first response to the request
  #
  def accept
    transaction do
      organization.contributors.create!(user: user)

      ContributorRequestResponse.accept!(self)
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    Rails.logger.error(e.message)
  else
    yield if block_given?
  end

  #
  # Declines the request
  #
  # @yield if this is the first response to the request
  #
  def decline
    ContributorRequestResponse.decline!(self)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    Rails.logger.error(e.message)
  else
    yield if block_given?
  end
end
