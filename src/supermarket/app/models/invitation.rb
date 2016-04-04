class Invitation < ActiveRecord::Base
  include Tokenable

  # Associations
  # --------------------
  belongs_to :organization

  # Validations
  # --------------------
  validates :token, presence: true
  validates :email, presence: true
  validates :organization, presence: true
  validates :email, format: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i

  # Callbacks
  # --------------------
  before_validation { generate_token }

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
