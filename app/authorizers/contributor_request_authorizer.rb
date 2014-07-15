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
end
