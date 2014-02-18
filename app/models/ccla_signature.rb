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
  validates_presence_of :company
  validates_presence_of :address_line_1
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :zip
  validates_presence_of :country
  validates_acceptance_of :agreement, allow_nil: false, on: :create

  # Accessors
  # --------------------
  attr_accessor :agreement

  # Scopes
  # --------------------
  scope :by_organization, ->{ where(id: select('DISTINCT ON(organization_id) id').order('organization_id, signed_at DESC')).order('signed_at ASC') }

  # Callbacks
  # --------------------
  before_create ->(record){ record.signed_at = Time.now }

  def name
    "#{first_name} #{last_name}"
  end

  #
  # Creates an associated organization and an admin contributor for said
  # organization then saves the signature.
  #
  # @return [Boolean]
  #
  def sign!
    transaction do
      create_organization!
      organization.contributors.create!(organization: organization, user: user, admin: true)
      save!
    end
  end
end
