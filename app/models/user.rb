class User < ActiveRecord::Base
  # Associations
  # --------------------
  has_many :accounts
  has_many :addresses
  has_many :emails
  has_many :icla_signatures
  has_one :primary_email, class_name: 'Email'

  # Validations
  # --------------------
  validates_presence_of :first_name, :last_name

  # Callbacks
  # --------------------
  before_validation :normalize_phone

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

  private

    #
    # Callback: strip anything that is not a digit from the phone number.
    #
    def normalize_phone
      phone.gsub!(/[^0-9]/, '') if phone
    end
end
