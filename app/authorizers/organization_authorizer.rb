class OrganizationAuthorizer < Authorizer::Base
  #
  # A user who is a Supermarket admin or is a member of an organization can view a +CclaSignature+
  #
  def view_cclas?
    user.is?(:admin) || user.organizations.include?(record)
  end

  #
  # An admin of an organization or Supermarket can resign a CCLA.
  #
  # @return [Boolean]
  #
  def resign_ccla?
    organization_or_supermarket_admin?
  end

  #
  # An admin of an organization or Supermarket can manage its invitations.
  #
  # @return [Boolean]
  #
  def manage_contributors?
    organization_or_supermarket_admin?
  end

  private

  def organization_or_supermarket_admin?
    user.is?(:admin) || user.admin_of_organization?(record)
  end
end
