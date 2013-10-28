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

  # Scope
  # --------------------
  scope :for, ->(id) { where(provider: id) }

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

      transaction do
        account = where(policy.signature).first_or_initialize do |account|
          account.username      = policy.username
          account.oauth_token   = policy.oauth_token
          account.oauth_secret  = policy.oauth_secret
          account.oauth_expires = policy.oauth_expires
        end

        user = account.user ||= User.create! do |user|
          user.first_name = policy.first_name
          user.last_name  = policy.last_name
        end

        # Some OmniAuth providers do not provide an email address
        unless policy.email.nil?
          email = user.emails.where(email: policy.email).first_or_create

          # Update the primary email if the User does not already have a
          # primary email
          user.primary_email ||= email
          user.save! if user.changed?
        end

        account.save!
        account
      end
    end
  end
end
