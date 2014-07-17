class ContributorRequest < ActiveRecord::Base
  belongs_to :organization
  belongs_to :ccla_signature
  belongs_to :user

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
end
