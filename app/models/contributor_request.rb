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
end
