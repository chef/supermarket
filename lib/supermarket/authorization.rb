require 'pundit'

module Supermarket
  module Authorization
    include Pundit
    extend ActiveSupport::Concern

    included do
      #
      # Make Pundit's +policy+ view helper accessible
      #
      helper_method :policy

      #
      # Make Pundit's +policy_scope+ view helper accessible
      #
      helper_method :policy_scope

      #
      # Alias Pundit's +authorize+ method to +authorize!+ for compatibility
      # with previous authorization library.
      #
      alias authorize! authorize
    end

  end
end
