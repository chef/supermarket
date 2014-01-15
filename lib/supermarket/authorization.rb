require 'pundit'

module Supermarket
  module Authorization
    include Pundit

    alias :authorize! :authorize

  end
end
