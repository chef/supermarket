class CclaSignature < ActiveRecord::Base
  include PgSearch
  include Exportable

  # Associations
  # --------------------
  belongs_to :user
  belongs_to :ccla
  belongs_to :organization

  # Validations
  # --------------------
  validates :user, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :phone, presence: true
  validates :company, presence: true
  validates :address_line_1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true
  validates :country, presence: true
  validates :agreement, acceptance: true, allow_nil: false, on: :create

  # Accessors
  # --------------------
  attr_accessor :agreement

  # Scopes
  # --------------------
  scope :by_organization, -> { latest.chronological }
  scope :latest, -> { where(id: select('DISTINCT ON(organization_id) id').order('organization_id, signed_at DESC')) }
  scope :earliest, -> { where(id: select('DISTINCT ON(organization_id) id').order('organization_id, signed_at ASC')) }
  scope :earliest_by_user, -> { where(id: select('DISTINCT ON(user_id) id').order('user_id, signed_at ASC')) }
  scope :chronological, -> { order('signed_at ASC') }

  # Callbacks
  # --------------------
  before_create -> (record) { record.signed_at ||= Time.now }

  # Search
  # --------------------
  pg_search_scope(
    :search,
    against: :company,
    using: {
      tsearch: { dictionary: 'english' },
      trigram: { threshold: 0.05 }
    }
  )

  def name
    "#{first_name} #{last_name}"
  end

  #
  # Creates an associated organization and an admin contributor for said
  # organization then saves the signature. Raises an exception and rolls
  # the database back if any record is unable to save.
  #
  def sign!
    transaction do
      create_organization!
      organization.contributors.create!(organization: organization, user: user, admin: true)
      save!
    end
  end
end
