module Supermarket
  module Authorization

    #
    # Custom error class raised when the user is not authorized to
    # perform an action.
    #
    class NotAuthorizedError < StandardError; end

    def self.included(controller)
      if controller.respond_to?(:helper_method)
        controller.send(:helper_method, :policy, :can?)
      end
    end

    #
    # The policy object for the associated record. The method makes some
    # assumptions about the name of the policy. It is assumed that policies
    # live in +app/policies/authorizers+ and are scoped under the
    # +Authorizers+ module.
    #
    # @example
    #   policy(@post) #=> #<Authorizers::PostPolicy ...>
    #
    # @raise [NotAuthorizedError]
    #   if not policy exists for the given record
    #
    # @param [Class] record
    #   the record to find a policy for
    #
    # @return [Policy]
    #
    def policy(record)
      klass = "Authorizers::#{policy_name(record)}".constantize
      klass.new(current_user, record)
    rescue NameError
      raise NotAuthorizedError, "No policy exists for #{record.class}," \
        " so all actions are assumed to be unauthorized!"
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
    # This method queries the policy object for the action.
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
      policy(record).public_send(action.to_s + '?')
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

    private

      #
      # Calculate the name of the policy from the given object. This is
      # useful when checking an array of records or ActiveRecord collection.
      #
      # @param [Object] record
      #
      # @return [String]
      #
      def policy_name(record)
        if record.respond_to?(:model_name)
          "#{record.model_name}Policy"
        elsif record.class.respond_to?(:model_name)
          "#{record.class.model_name}Policy"
        elsif record.is_a?(Class)
          "#{record}Policy"
        else
          "#{record.class}Policy"
        end
      end
    end
end
