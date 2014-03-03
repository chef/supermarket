module Supermarket
  module LocationStorage
    #
    # Stores the current request URL or the root URL
    # in a session variable.
    #
    # @example
    #   store_location!
    #
    def store_location!
      session[storage_key] = request.url || root_url
    end

    #
    # Returns the previously set stored location
    # or nil if no location is stored.
    #
    # @example
    #   stored_location
    #
    # @return [String, nil]
    #
    def stored_location
      session.delete(storage_key)
    end

    private

    def storage_key
      "location_storage_return_to"
    end
  end
end
