module Authorizer
  class Base
    # @return [User]
    attr_reader :user

    # @return [Object]
    attr_reader :record

    #
    # Create a new authorizer for the given user and record.
    #
    # @param [User] user
    # @param [Object] record
    #
    def initialize(user, record)
      @user = user || User.new
      @record = record
    end

    #
    # In development and test, raise an exception if a method is called that
    # isn't defined on the parent class. In other environments, just return
    # false, assuming the action is unauthorized.
    #
    # @raise [RuntimeError]
    #   in development and test, when an undefined method is called
    #
    def method_missing(m, *args, &block)
      if Rails.env.development? || Rails.env.test?
        raise RuntimeError, "#{self.class.name} does not define #{m}!"
      else
        false
      end
    end
  end
end
