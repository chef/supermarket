require 'authorizer/base'

class ClaSignatureAuthorizer < Authorizer::Base
  #
  # Any user view the ClaSignature index.
  #
  # @return [Boolean]
  #
  def index?
    true
  end

  #
  # A user who is an admin or is the user who created the +ClaSignature+ can view
  # the +ClaSignature+.
  #
  # @return [Boolean]
  #
  def show?
    user.is?(:admin) || record.user_id == user.id
  end

  #
  # Any user can create a +ClaSignature+.
  #
  # @return [Boolean]
  #
  def create?
    true
  end

  #
  # A user who can view the +ClaSignature+ can update the +ClaSignature+.
  #
  # @return [Boolean]
  #
  def update?
    show?
  end

  #
  # A user who can view the +ClaSignature+ can update the +ClaSignature+.
  #
  # @return [Boolean]
  #
  def edit?
    show?
  end

  #
  # A user who can view the +ClaSignature+ can delete the +ClaSignature+.
  #
  # @return [Boolean]
  #
  def destroy?
    show?
  end

  #
  # Any user can view the new form for creating a +ClaSignature+.
  #
  # @return [Boolean]
  #
  def new?
    true
  end
end
