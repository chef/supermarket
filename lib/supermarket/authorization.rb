require 'pundit'

module Supermarket
  module Authorization
    include Pundit

    alias :authorize! :authorize

    #
    # Authorization action ensuring the current user exists.
    #
    # @raise [NotAuthorizedError]
    #   if the user is not currently logged in
    #
    def require_valid_user!
      unless current_user
        raise NotAuthorizedError, 'You must be signed in to perform that' \
          ' action!'
      end
    end

  end
end
