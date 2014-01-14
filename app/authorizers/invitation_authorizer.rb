class InvitationAuthorizer < Authorizer::Base
  def index?
    user.organization_users.where(admin: true)
      .map(&:organization).include?(record.organization)
  end

  def create?
    index?
  end
end
