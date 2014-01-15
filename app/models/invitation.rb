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

  def to_param
    token
  end

  def accept
    update_attributes(accepted: true)
  end

  def reject
    update_attributes(accepted: false)
  end
end
