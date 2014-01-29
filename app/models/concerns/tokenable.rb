#
# @todo maybe refactor this into "Confirmable"?
#
module Tokenable
  private

  #
  # Callback: create and assign a confirmation token when a new email is added.
  #
  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while self.class.exists?(column => self[column])
  end
end
