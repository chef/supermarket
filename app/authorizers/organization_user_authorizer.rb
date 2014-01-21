require 'authorizer/base'

class OrganizationUserAuthorizer < Authorizer::Base

  alias contributor record

  def destroy?
    organization = contributor.organization

    if user.is_admin_of_organization?(organization)
      if contributor.admin?
        not contributor.only_admin?
      else
        true
      end
    end
  end

end
