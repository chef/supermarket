class Invitation < ActiveRecord::Base
  include Tokenable

  # Associations
  # --------------------
  belongs_to :organization

  # Validations
  # --------------------
  validates_presence_of :token
  validates_presence_of :email
  validates_presence_of :organization

  # Callbacks
  # --------------------
  before_validation { generate_token(:token) }

  scope :pending, -> { where(accepted: nil) }
  scope :declined, -> { where(accepted: false) }

  #
  # Returns the invitation identified by the given token
  #
  # @raise [ActiveRecord::RecordNotFound] if there is no such invitation
  #
  # @return [Invitation] the invitation
  #
  def self.with_token!(token)
    find_by!(token: token)
  end

  def to_param
    token
  end

  def accept
    update_attributes(accepted: true)
  end

  def decline
    update_attributes(accepted: false)
  end
end
