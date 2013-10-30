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
    # Creates a new +Account+ (or updates an existing one) from the given
    # oauth hash. The +provider+ and +uid+ values are used as a composite
    # key to uniquely identify the credentials.
    #
    # @param [OmniAuth::AuthHash]
    #
    # @return [Account]
    #
    def from_oauth(auth)
      extractor = Extractor::Base.load(auth)

      transaction do
        account = where(extractor.signature).first_or_initialize do |account|
          account.username      = extractor.username
          account.oauth_token   = extractor.oauth_token
          account.oauth_secret  = extractor.oauth_secret
          account.oauth_expires = extractor.oauth_expires
        end

        user = account.user ||= User.create! do |user|
          user.first_name = extractor.first_name
          user.last_name  = extractor.last_name
        end

        # Some OmniAuth providers do not provide an email address
        unless extractor.email.nil?
          email = user.emails.where(email: extractor.email).first_or_create

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
