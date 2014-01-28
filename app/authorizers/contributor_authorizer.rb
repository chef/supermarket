require 'authorizer/base'

class ContributorAuthorizer < Authorizer::Base
  alias contributor record

  #
  # A user who is an admin of the contributor's organization while the
  # contributor is not an admin can delete a +Contributor+.
  #
  # A user who is an admin of the contributor's organization while the contributor
  # is not the last admin can can delete a +Contributor+.
  #
  # @return [Boolean]
  #
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

  #
  # A user who can destroy a +Contributor+ can update a +Contributor+.
  #
  # @return [Boolean]
  #
  def update?
    destroy?
  end
end

