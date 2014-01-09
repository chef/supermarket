class CclaSignatureAuthorizer < Authorizer::Base
  def index?
    true
  end

  def show?
    if user.is?(:admin, :api, :employee, :legal)
      true
    else
      record.user_id == user.id
    end
  end

  def create?
    if user.is?(:admin, :legal)
      true
    else
      record.user_id == user.id
    end
  end

  def new?
    create?
  end

  def update?
    user.is?(:admin, :legal)
  end

  def edit?
    update?
  end

  def destroy?
    user.is?(:admin, :legal)
  end
end
