class OrganizationUserAuthorizer < Authorizer::Base

  alias contributor record

  def destroy?
    organization = contributor.organization

    if user.is_admin_of_organization?(organization)
      if contributor.admin?
        organization.admins.count > 1
      else
        true
      end
    end
  end

end
