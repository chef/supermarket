#
# @todo maybe refactor this into "Confirmable"?
#
module Tokenable
  private

  #
  # Callback: create and assign a confirmation token when a new email is added.
  #
  def generate_token(column = :token)
    loop do
      self[column] = SecureRandom.hex
      break unless self.class.exists?(column => self[column])
    end
  end
end
