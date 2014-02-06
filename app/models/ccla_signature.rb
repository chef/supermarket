class CclaSignature < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :user
  belongs_to :ccla
  belongs_to :organization

  # Validations
  # --------------------
  validates_presence_of :user
  validates_acceptance_of :agreement, allow_nil: false, on: :create

  # Accessors
  # --------------------
  attr_accessor :agreement

  # Accepts Nested Attributes
  # --------------------
  accepts_nested_attributes_for :organization, update_only: true

  def name
    "#{first_name} #{last_name}"
  end
end
