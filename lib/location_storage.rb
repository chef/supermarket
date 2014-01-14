module LocationStorage

  def store_location!
    session[storage_key] = request.url || root_url
  end

  def stored_location
    session.delete(storage_key)
  end

  private

  def storage_key
    "location_storage_return_to"
  end

end
