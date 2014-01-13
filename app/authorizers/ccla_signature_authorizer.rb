class CclaSignatureAuthorizer < ClaSignatureAuthorizer
  def show?
    if user.is?(:admin)
      true
    else
      user.organizations.include?(record.organization)
    end
  end
end
