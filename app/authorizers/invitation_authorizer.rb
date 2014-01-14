class InvitationAuthorizer < Authorizer::Base

  def create?
    true
  end

  def index?
    true
  end

end
