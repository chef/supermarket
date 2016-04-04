require 'authorizer/base'

class UserAuthorizer < Authorizer::Base
  #
  # Admins can make other non admin users admins.
  #
  def make_admin?
    user.is?(:admin) && !record.is?(:admin)
  end

  #
  # Admins can revoke other admin users admin role.
  #
  def revoke_admin?
    user.is?(:admin) && user != record
  end
end
