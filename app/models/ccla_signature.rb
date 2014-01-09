class CclaSignature < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :user
  belongs_to :ccla

  # Accessors
  # --------------------
  attr_accessor :agreement

  def name
    "#{first_name} #{last_name}"
  end
end
