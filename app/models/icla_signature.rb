class IclaSignature < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :user
  belongs_to :icla

  # Validations
  # --------------------
  validates_presence_of :user
  validates_acceptance_of :agreement, allow_nil: false, on: :create

  # Accessors
  # --------------------
  attr_accessor :agreement

  # Scopes
  # --------------------
  scope :by_user, ->{ includes(:user).order('users.last_name, users.first_name') }


  # Accepts Nested Attributes
  # --------------------
  accepts_nested_attributes_for :user, update_only: true

  # Callbacks
  # --------------------
  before_create ->(record){ record.signed_at = Time.now }
end
