class User < ActiveRecord::Base
  include Authorizable

  # Associations
  # --------------------
  has_many :accounts
  has_many :emails
  has_many :icla_signatures
  has_many :ccla_signatures
  has_many :organization_users
  has_many :organizations, through: :organization_users
  belongs_to :primary_email, class_name: 'Email'

  # Validations
  # --------------------
  validates_presence_of :first_name
  validates_presence_of :last_name

  # Callbacks
  # --------------------
  before_validation :normalize_phone

  class << self
    #
    # Creates a new +User+ from the given oauth hash, updating or creating
    # the nested account as well.
    #
    # @see Account.from_oauth
    #   for more information about the +user+ parameter
    #
    # @param [OmniAuth::AuthHash]
    # @param [User, nil]
    #
    # @return [Account]
    #
    def from_oauth(auth, user = nil)
      Account.from_oauth(auth, user).user
    end
  end

  #
  # Determine if the current user signed the Individual Contributor License
  # Agreement.
  #
  # @todo Expand this functionality to search for the most recently active
  #       ICLA and return some sort of history instead.
  #
  # @return [Boolean]
  #
  def signed_icla?
    !icla_signatures.empty?
  end

  #
  # The name of the current user.
  #
  # @example
  #   user.name #=> "Seth Vargo"
  #
  # @return [String]
  #
  def name
    [first_name, last_name].join(' ')
  end

  #
  # Determine if the current user is an admin of a given organization
  #
  # @example
  #   user.is_admin_of_organization?(organization)
  #
  # @param [Organization]
  #
  # @return [Boolean]
  #
  def is_admin_of_organization?(organization)
    organizations.joins(:organization_users).where(
      'organization_users.admin = ? AND organizations.id = ?',
      true, organization.id).count > 0
  end

  private

    #
    # Callback: strip anything that is not a digit from the phone number.
    #
    def normalize_phone
      phone.gsub!(/[^0-9]/, '') if phone
    end
end
