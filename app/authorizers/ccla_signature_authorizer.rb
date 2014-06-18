class CclaSignatureAuthorizer < ClaSignatureAuthorizer
  alias_method :ccla_signature, :record

  #
  # A user who is a Supermarket admin or is a member of the CCLA signature's
  # organization can view a +CclaSignature+.
  #
  # @return [Boolean]
  #
  def show?
    if user.is?(:admin)
      true
    else
      user.organizations.include?(ccla_signature.organization)
    end
  end

  #
  # A user who is a Supermarket admin or is an admin of the CCLA signature's
  # organization can manage the contributors a +CclaSignature+.
  #
  # @return [Boolean]
  #
  def manage_contributors?
    if user.is?(:admin)
      true
    else
      user.admin_of_organization?(ccla_signature.organization)
    end
  end
end
