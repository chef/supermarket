module Supermarket
  module ProtectedResource

    def policy_class
      "#{name}Authorizer"
    end

  end
end
