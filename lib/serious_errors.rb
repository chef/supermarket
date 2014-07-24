module SeriousErrors
  #
  # Return full error messages
  #
  # @return [Array<String>] error messages
  #
  def seriously_all_of_the_errors
    errors.full_messages
  end
end
