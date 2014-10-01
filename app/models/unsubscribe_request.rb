class UnsubscribeRequest < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :user

  # Validations
  # --------------------
  validates :user, presence: true
  validates :token, presence: true
  validates :email_preference_name, presence: true

  # Callbacks
  # --------------------
  before_validation :ensure_token

  #
  # This method does the main work of this class, namely finding the
  # appropriate user, removing the appropriate preference from their
  # email_preferences list, and then deleting itself and any other
  # UnsubscribeRequests for the same email, and the same user.
  #
  def make_it_so
    user.email_preferences.delete(email_preference_name.to_sym)
    user.save
    self.class.where(
      email_preference_name: email_preference_name,
      user_id: user_id
    ).delete_all
  end

  def to_param
    token
  end

  private

  #
  # This ensures there's a token present when a request is created.
  #
  def ensure_token
    self.token = SecureRandom.hex if token.blank?
  end
end
