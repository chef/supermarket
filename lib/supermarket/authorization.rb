module Supermarket
  module Authorization
    include LocationStorage

    #
    # Custom error class raised when an authorizer does not exist.
    #
    class NoAuthorizerError < StandardError; end

    #
    # Custom error class raised when the user is not authorized to
    # perform an action.
    #
    class NotAuthorizedError < StandardError; end

    def self.included(controller)
      controller.send(:helper_method, :authorizer, :can?)
    end

    #
    # The authorizer object for the associated record. The method makes some
    # assumptions about the name of the authorizer. It is assumed that
    # authorizers live in +app/authorizers+ and end in +Authorizer+.
    #
    # @example
    #   authorizer(@post) #=> #<PostAuthorizer ...>
    #
    # @raise [NotAuthorizedError]
    #   if no authorizer exists for the given record
    #
    # @param [Class] record
    #   the record to find a authorizer for
    #
    # @return [~Authorizer]
    #
    def authorizer(record)
      klass = "#{authorizer_name(record)}Authorizer".constantize
      klass.new(current_user, record)
    rescue NameError
      raise NoAuthorizerError, "No authorizer exists for" \
        " #{authorizer_name(record)}, so all actions are assumed to be" \
        " unauthorized!"
    end

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
      authorizer(record).public_send(action.to_s + '?')
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
    # Authorize the current controller action, raising an exception if the
    # current user is not authorized to perform that action. In controller
    # methods, this is probably the method you want to use.
    #
    # @raise [NotAuthorizedError]
    #   if the current user is not authorized to perform the current
    #   controller action
    #
    # @param [Class] record
    #   the record to check authorization against
    #
    def authorize!(record)
      unless authorized?(record)
        raise NotAuthorizedError, "You are not authorized to" \
          " #{params[:action]} #{record.class.to_s.pluralize}!"
      end
    end

    #
    # Authorization action ensuring the current user exists.
    #
    # @raise [NotAuthorizedError]
    #   if the user is not currently logged in
    #
    def require_valid_user!
      unless current_user
        store_location!
        raise NotAuthorizedError, 'You must be signed in to perform that' \
          ' action!'
      end
    end

    private

      #
      # Calculate the name of the authorizer from the given object. This is
      # useful when checking an array of records or ActiveRecord collection.
      #
      # @param [Object] record
      #
      # @return [String]
      #
      def authorizer_name(record)
        if record.respond_to?(:model_name)
          record.model_name.to_s
        elsif record.class.respond_to?(:model_name)
          record.class.model_name.to_s
        elsif record.is_a?(Class)
          record.to_s
        else
          record.class.to_s
        end
      end
    end
end
