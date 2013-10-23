class Email < ActiveRecord::Base
  include Tokenable

  # Associations
  # --------------------
  belongs_to :user

  # Validations
  # --------------------
  validates_presence_of :user
  validates_presence_of :email
  validates_uniqueness_of :email

  # Callbacks
  # --------------------
  before_create { generate_token(:confirmation_token) }

  #
  # Determine if this email address has been confirmed.
  #
  # @return [Boolean]
  #
  def confirmed?
    !confirmed_at.nil?
  end
end
