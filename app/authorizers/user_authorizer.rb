require 'authorizer/base'

class UserAuthorizer < Authorizer::Base
  #
  # Admins can make other non admin users admins.
  #
  def make_admin?
    user.is?(:admin) && !record.is?(:admin)
  end
end
