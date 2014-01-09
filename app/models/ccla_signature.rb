class CclaSignature < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :user
  belongs_to :ccla
  belongs_to :organization

  # Validations
  # --------------------
  validates_presence_of :user
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_presence_of :phone
  validates_presence_of :address_line_1
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :zip
  validates_presence_of :country
  validates_acceptance_of :agreement, allow_nil: false

  # Accessors
  # --------------------
  attr_accessor :agreement

  def name
    "#{first_name} #{last_name}"
  end
end
