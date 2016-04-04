module Supermarket
  module LocationStorage
    #
    # Stores the current request URL or the root URL
    # in a session variable.
    #
    # @param [String] location the location to store
    #
    # @example
    #   store_location!
    #   store_location!(profile_path)
    #
    def store_location!(location = request.path)
      session[storage_key] = location || root_path
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
      'location_storage_return_to'
    end
  end
end
