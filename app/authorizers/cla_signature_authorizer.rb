class ClaSignatureAuthorizer < Authorizer::Base
  def index?
    true
  end

  def show?
    user.is?(:admin) || record.user_id == user.id
  end

  def create?
    true
  end

  def update?
    show?
  end

  def edit?
    show?
  end

  def destroy?
    show?
  end
end
