class Invitation < ActiveRecord::Base
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
  before_validation :generate_token

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
end
