require 'authorizer/base'

class ContributorRequestAuthorizer < Authorizer::Base
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
