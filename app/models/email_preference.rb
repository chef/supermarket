class EmailPreference < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :system_email
  belongs_to :user

  # Validations
  # --------------------
  validates :user, presence: true
  validates :system_email, presence: true
  validates :token, uniqueness: true

  # Callbacks
  # --------------------
  before_validation :ensure_token

  #
  # Setup a default set of +EmailPreference+s for a +User+. This is called when
  # a +User+ is first created, and subscribes that +User+ to all available
  # emails.
  #
  # @param user [User] the +User+ to subscribe emails to
  #
  def self.default_set_for_user(user)
    SystemEmail.all.each do |email|
      EmailPreference.where(user: user, system_email: email).first_or_create!
    end
  end

  #
  # Return the token in URLs
  #
  # @return [String] the token for this object
  #
  def to_param
    token
  end

  private

  #
  # Ensure that a token exists when this object is created
  #
  def ensure_token
    self.token = SecureRandom.hex
  end
end
