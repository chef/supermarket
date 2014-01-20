class InvitationAuthorizer < Authorizer::Base
  def index?
    user.is_admin_of_organization?(record.organization)
  end

  def create?
    index?
  end
end
