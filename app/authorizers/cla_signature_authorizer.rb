class ClaSignatureAuthorizer < Authorizer::Base
  def index?
    true
  end

  def show?
    if user.is?(:admin)
      true
    else
      record.user_id == user.id
    end
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
