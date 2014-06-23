class OrganizationAuthorizer < Authorizer::Base
  #
  # An admin of an organization can manage its invitations.
  #
  # @return [Boolean]
  #
  def manage_invitations?
    user.admin_of_organization?(record)
  end
end
