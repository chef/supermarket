class InvitationAuthorizer < Authorizer::Base
  def index?
    user.admin_of_organization?(record.organization)
  end

  def create?
    index?
  end

  def update?
    index?
  end

  def resend?
    index?
  end

  def revoke?
    index?
  end
end
