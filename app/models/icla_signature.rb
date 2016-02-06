class IclaSignature < ActiveRecord::Base
  include Exportable
  # Associations
  # --------------------
  belongs_to :user
  belongs_to :icla

  # Validations
  # --------------------
  validates :user, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :phone, presence: true
  validates :address_line_1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true
  validates :country, presence: true
  validates :agreement, acceptance: true, on: :create

  # Accessors
  # --------------------
  attr_accessor :agreement

  # Scopes
  # --------------------
  scope :by_user, -> { includes(user: :accounts).latest.chronological }
  scope :latest, -> { where(id: select('DISTINCT ON(user_id) id').order('user_id, signed_at DESC')) }
  scope :earliest, -> { where(id: select('DISTINCT ON(user_id) id').order('user_id, signed_at ASC')) }
  scope :chronological, -> { order('signed_at ASC') }

  # Callbacks
  # --------------------
  before_create -> (record) { record.signed_at ||= Time.current }

  def name
    "#{first_name} #{last_name}"
  end
end
