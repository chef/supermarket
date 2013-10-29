module Authorizers
  module Authorizer
    def self.included(base)
      base.send(:attr_reader, :user)
      base.send(:attr_reader, :record)
    end

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
        raise RuntimeError, "#{self.class} does not define #{m}!"
      else
        super
      end
    end
  end
end
