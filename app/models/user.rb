class User < ActiveRecord::Base
  # Associations
  # --------------------
  has_many :accounts
  has_many :emails
  has_many :icla_signatures
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
    # @param [OmniAuth::AuthHash]
    #
    # @return [Account]
    #
    def from_oauth(auth)
      Account.from_oauth(auth).user
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

  private

    #
    # Callback: strip anything that is not a digit from the phone number.
    #
    def normalize_phone
      phone.gsub!(/[^0-9]/, '') if phone
    end
end
