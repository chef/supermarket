class User < ApplicationRecord
  include Authorizable
  include PgSearch

  ALLOWED_INSTALL_PREFERENCES = %w[berkshelf knife librarian policyfile].freeze

  # Associations
  # --------------------
  has_many :accounts
  has_many :owned_cookbooks, class_name: 'Cookbook', foreign_key: 'user_id', inverse_of: :owner
  has_many :cookbook_versions
  has_many :collaborators
  has_many :cookbook_followers
  has_many :followed_cookbooks, through: :cookbook_followers, source: :cookbook
  has_many :collaborated_cookbooks, through: :collaborators, source: :resourceable, source_type: 'Cookbook'
  has_many :tools
  has_many :collaborated_tools, through: :collaborators, source: :resourceable, source_type: 'Tool'
  has_many :email_preferences
  has_many :system_emails, through: :email_preferences
  has_one :chef_account, -> { self.for('chef_oauth2') }, class_name: 'Account', inverse_of: :user
  has_one :github_account, -> { self.for('github') }, class_name: 'Account', inverse_of: :user
  has_many :group_members
  has_many :memberships, through: :group_members, source: :group
  has_many :initiated_ownership_transfer_requests, class_name: 'OwnershipTransferRequest', foreign_key: :sender_id, inverse_of: :sender
  has_many :received_ownership_transfer_requests, class_name: 'OwnershipTransferRequest', foreign_key: :recipient_id, inverse_of: :recipient

  # Validations
  # --------------------
  validates :email, presence: true

  # Callbacks
  # --------------------
  after_create :default_email_preferences

  # Scope
  # --------------------
  scope :with_email, ->(email) { where(email: email) }
  scope :with_username, ->(username) { joins(:chef_account).where('accounts.username' => username) }

  # Search
  # --------------------
  pg_search_scope(
    :search,
    against: {
      first_name: 'A',
      last_name: 'B',
      email: 'C'
    },
    associated_against: {
      chef_account: :username,
      github_account: :username
    },
    using: {
      tsearch: { prefix: true, dictionary: 'english' },
      trigram: { threshold: 0.2 }
    }
  )

  accepts_nested_attributes_for :email_preferences, allow_destroy: true

  #
  # Return the +EmailPreference+ for the name given. The name in question
  # should be the name of an existing +SystemEmail+.
  #
  # @param name [String] the name of the +SystemEmail+ to find for this +User+
  #
  # @return [EmailPreference] the +EmailPreference+ that matches the
  # +SystemEmail+ in question
  #
  def email_preference_for(name)
    email_preferences.includes(:system_email)
                     .find_by(system_emails: { name: name })
  end

  #
  # Returns all +CookbookVersion+ instances that +User+ follows.
  #
  # @return [CookbookVersion]
  #
  def followed_cookbook_versions
    CookbookVersion.joins(:cookbook).
      merge(followed_cookbooks).
      order('created_at DESC')
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
    if first_name.present? || last_name.present?
      [first_name, last_name].join(' ').strip
    else
      username
    end
  end

  #
  # Find or initialize an account based on a hash
  # most typically an OAuth response
  #
  # @example
  #   user.account_from_oauth(request.env['omniauth.auth'])
  #
  # @param auth [Hash] the account information, formatted like OmniAuth schema
  #
  # @return [Account]
  #
  def account_from_oauth(auth)
    extractor = Extractor::Base.load(auth)

    accounts.where(extractor.signature).first_or_initialize do |account|
      account.username      = extractor.username
      account.oauth_token   = extractor.oauth_token
      account.oauth_secret  = extractor.oauth_secret
      account.oauth_expires = extractor.oauth_expires
    end
  end

  #
  # Determine if the user has linked any GitHub accounts
  #
  # @example
  #   user.linked_github_account? #=> false
  #   user.accounts.create(
  #     provider: 'github',
  #     uid: '1234',
  #     oauth_token: 'token'
  #   )
  #   user.linked_github_account? #=> true
  #
  # @return [Boolean]
  #
  def linked_github_account?
    accounts.for('github').any?
  end

  #
  # The user's Chef ID username. Will be blank in the event the user has
  # unlinked their Chef ID.
  #
  # @return [String] the username for that Chef ID
  #
  def username
    chef_account.try(:username).to_s
  end

  #
  # Find or create a user based on the oc-id auth hash. If the user already
  # exists, its +first_name+, +last_name+, and +public_key+ will be updated to
  # reflect the extracted values.
  #
  # @example
  #   user = User.find_or_create_from_chef_oauth(
  #     uid: '123',
  #     provider: 'chef_oauth2'
  #   )
  #
  # @param [Hash] auth the OmniAuth hash returned from the oc-id provider
  #
  # @return [User] the user that exists or was created with the +auth+
  #                information
  #
  def self.find_or_create_from_chef_oauth(auth)
    extractor = ChefOauth2Extractor.new(auth)

    account = Account.where(extractor.signature).first_or_initialize

    if account.new_record?
      account.user = User.new
    end

    account.assign_attributes(
      username: extractor.username,
      oauth_token: extractor.oauth_token,
      oauth_secret: extractor.oauth_secret,
      oauth_expires: extractor.oauth_expires,
      oauth_refresh_token: extractor.oauth_refresh_token
    )

    account.user.assign_attributes(
      public_key: extractor.public_key,
      first_name: extractor.first_name,
      last_name: extractor.last_name,
      email: extractor.email
    )

    transaction do
      account.save
      account.user.save
    end

    account.user
  end

  def to_param
    username
  end

  #
  # Updates the user's cookbook install preference to that specified in the
  # parameter if that parameter is part of the
  # +User::ALLOWED_INSTALL_PREFERENCES+.
  #
  # @param [String] preference - the value to update it to
  #
  # @return [Boolean] whether or not the user was successfully updated
  #
  def update_install_preference(preference)
    if ALLOWED_INSTALL_PREFERENCES.include?(preference)
      self.install_preference = preference
      save
    else
      false
    end
  end

  def public_key_signature
    return nil if public_key.blank?
    # Inspired by https://stelfox.net/blog/2014/04/calculating-rsa-key-fingerprints-in-ruby/
    # Verifiable by an end-user either:
    #   with private key: openssl rsa -in private_key.pem -pubout -outform DER | openssl md5 -c
    #   with public key: openssl rsa -in public_key.pub -pubin -outform DER | openssl md5 -c
    key_in_der_format = OpenSSL::PKey::RSA.new(public_key).to_der
    OpenSSL::Digest::MD5.hexdigest(key_in_der_format).scan(/../).join(':')
  end

  private

  #
  # Subscribe new users to all emails by default
  #
  def default_email_preferences
    EmailPreference.default_set_for_user(self) if email_preferences.blank?
  end
end
