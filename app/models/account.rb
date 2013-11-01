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
    # If the second optional parameter (+user+) is given and the account does
    # not yet exist, it will be associated with the user. Otherwise, a new
    # one will be created.
    #
    # Accounts search Email records to see if an email address corresponds to
    # information contained in the OmniAuth hash. If an Email exists, the new
    # Account object will be associated with the User object associated with
    # the Email record.
    #
    # Accounts search IclaSignature records to see if an email address
    # corresponds to information contained in the OmniAuth hash. If an Icla
    # Signature exists with the given email address, the new Account object
    # will be associated with the User object associated with the Icla
    # Signature record.
    #
    # This method will set the parent User object's +primary_email+ if it is
    # not already set.
    #
    # @param [OmniAuth::AuthHash]
    # @param [User, nil]
    #
    # @return [Account]
    #
    def from_oauth(auth, user = nil)
      extractor = Extractor::Base.load(auth)

      transaction do
        account = where(extractor.signature).first_or_initialize do |account|
          account.username      = extractor.username
          account.oauth_token   = extractor.oauth_token
          account.oauth_secret  = extractor.oauth_secret
          account.oauth_expires = extractor.oauth_expires
        end

        account.user ||= user ||= find_or_create_user(extractor)

        # Some OmniAuth providers do not provide an email address
        unless extractor.email.nil?
          user = account.user
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

    private

      #
      # Find or create a new user from the given extractor.
      #
      # @param [~Extractor]
      #
      # @return [User]
      #
      def find_or_create_user(extractor)
        Email.find_by_email(extractor.email).try(:user) ||
        IclaSignature.find_by_email(extractor.email).try(:user) ||
        User.create! do |user|
          user.first_name = extractor.first_name
          user.last_name  = extractor.last_name
        end
      end
  end
end
