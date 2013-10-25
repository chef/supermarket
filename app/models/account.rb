class Account < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :user

  # Validations
  # --------------------
  validates_presence_of :user
  validates_presence_of :uid
  validates_presence_of :provider
  validates_presence_of :oauth_token

  # Callbacks
  # --------------------

  class << self
    #
    # Creates a new +Account+ (or updates an existing one) from the given oauth
    # hash. The +provider+ and +uid+ values are used as a composite key to
    # uniquely identify the credentials.
    #
    # @param [OmniAuth::AuthHash]
    #
    # @return [Account]
    #
    def from_oauth(auth)
      policy = OmniAuth::Policy.load(auth)

      where(policy.signature).first_or_initialize do |account|
        account.username      = policy.username
        account.oauth_token   = policy.oauth_token
        account.oauth_secret  = policy.oauth_secret
        account.oauth_expires = policy.oauth_expires
      end
    end
  end
end
