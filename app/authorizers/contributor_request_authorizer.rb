require 'authorizer/base'

class ContributorRequestAuthorizer < Authorizer::Base
  #
  # Only users who don't already belong to the organization can make requests
  #
  # @return [Boolean]
  #
  def create?
    record.organization.contributors.where(user_id: user.id).empty?
  end

  #
  # Only admins of the organization which the requestor would like to join may
  # accept a request to join that organization
  #
  # @return [Boolean]
  #
  def accept?
    record.presiding_admins.include?(user)
  end
end
