require 'pundit'

module Supermarket
  module Authorization
    include Pundit

    def self.included(controller)
      controller.send(:helper_method, :can?)
    end

    alias :authorize! :authorize

    #
    # Convenient wrapper method used in controllers for authorizing actions.
    # This method is actually just a wrapper around the {can?} method, but
    # the +action+ is assumed to be the current controller action.
    #
    # @example
    #   def create
    #     authorized?(@post) #=> can?(:create, @post) #=> true
    #   end
    #
    # @see can?
    #
    # @param [Class] record
    #   the record to check authorization against
    #
    # @return [Boolean]
    #
    def authorized?(record)
      can?(params[:action], record)
    end

    #
    # Determine if the current user is eligible to perform the given action.
    # This method queries the authorizer object for the action.
    #
    # @example
    #   if can?(:create, @post)
    #     <%= link_to 'New Post', new_post_path %>
    #   end
    #
    # @param [String, Symbol] action
    #   the action to check
    # @param [Class] record
    #   the record to check authorization against
    #
    # @return [Boolean]
    #
    def can?(action, record)
      begin
        authorize(record, action.to_s + '?')
      rescue NotAuthorizedError
        false
      end
    end

    #
    # The opposite of {can?}
    #
    # @see can?
    #
    def cannot?(action, record)
      !can?(action, record)
    end

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
