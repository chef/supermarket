class User < ActiveRecord::Base
  include Authorizable
  include PgSearch

  ALLOWED_INSTALL_PREFERENCES = %w(berkshelf knife librarian)

  # Associations
  # --------------------
  has_many :accounts
  has_many :icla_signatures
  has_many :ccla_signatures
  has_many :contributors
  has_many :organizations, through: :contributors
  has_many :owned_cookbooks, class_name: 'Cookbook', foreign_key: 'user_id'
  has_many :collaborators
  has_many :cookbook_followers
  has_many :followed_cookbooks, through: :cookbook_followers, source: :cookbook
  has_many :collaborated_cookbooks, through: :collaborators, source: :resourceable, source_type: 'Cookbook'
  has_many :tools
  has_many :collaborated_tools, through: :collaborators, source: :resourceable, source_type: 'Tool'
  has_many :email_preferences
  has_many :system_emails, through: :email_preferences
  has_one :chef_account, -> { self.for('chef_oauth2') }, class_name: 'Account'
  has_many :group_members
  has_many :memberships, through: :group_members, source: :group

  # Validations
  # --------------------
  validates_presence_of :email

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
      chef_account: :username
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
    email_preferences.includes(:system_email).
      where(system_emails: { name: name }).first
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
  # The commit author identities who have signed a CLA
  #
  # @return [Array<Curry::CommitAuthor>]
  #
  def verified_commit_author_identities
    accounts.for(:github).map do |account|
      Curry::CommitAuthor.with_login(account.username).where(authorized_to_contribute: true)
    end.flatten
  end

  #
  # The commit author identities who have not signed a CLA
  #
  # @return [Array<Curry::CommitAuthor>]
  #
  def unverified_commit_author_identities
    accounts.for(:github).map do |account|
      Curry::CommitAuthor.with_login(account.username).where(authorized_to_contribute: false)
    end.flatten
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
    icla_signatures.any?
  end

  #
  # Retrieve the current users latest ICLA signature if they have signed a
  # ICLA.
  #
  # @return [IclaSignature]
  #
  def latest_icla_signature
    icla_signatures.order(:signed_at).last
  end

  #
  # Retrieve the current users latest CCLA signature if they have signed a
  # CCLA.
  #
  # @return [IclaSignature]
  #
  def latest_ccla
    ccla_signatures.order(:signed_at).last
  end

  #
  # Determine if the user is a contributor on behalf of one or more
  # +Organization+s
  #
  # @return [Boolean]
  #
  def contributor?
    contributors.any?
  end

  #
  # A user is authorized to contribute if they have signed the ICLA or are a
  # contributor on behalf of one or more organizations.
  #
  def authorized_to_contribute?
    signed_icla? || contributor?
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
    if first_name || last_name
      [first_name, last_name].join(' ').strip
    else
      username
    end
  end

  #
  # Determine if the current user is an admin of a given organization
  #
  # @example
  #   user.admin_of_organization?(organization)
  #
  # @param organization [Organization] the organization
  #
  # @return [Boolean]
  #
  def admin_of_organization?(organization)
    organizations.joins(:contributors).where(
      'contributors.admin = ? AND organizations.id = ?',
      true, organization.id).count > 0
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
  # Determines if the user has an outstanding request to join the given
  # +organization+
  #
  # @return [Boolean]
  #
  def requested_to_join?(organization)
    ContributorRequest.where(
      organization_id: organization.id,
      user_id: id
    ).first.try(:pending?)
  end

  #
  # Returns the pending +ContributorRequest+s for the user. Eager loads the
  # associated +ContributorRequestResponse+ because it is used in
  # +ContributorRequest#pending+. Eager loads the associated +Organization+ and
  # +CclaSignature+ because they are used in the views to display and link to
  # the +Organization+.
  #
  # @return [Array<ContributorRequest>] array of pending +ContributorRequest+s
  #
  def pending_contributor_requests
    ContributorRequest.includes(
      :contributor_request_response,
      :organization,
      :ccla_signature
    ).where(
      user: self
    ).select(&:pending?)
  end

  #
  # Returns a unique +ActiveRecord::Relation+ of all users who have signed
  # either the ICLA or CCLA or are a contributor on behalf of one or
  # more +Organization+s. Sorts the users by their Chef account username.
  #
  # NOTE: this does not eager load the accounts for users. Do not make any calls
  # that use the user's accounts, like
  # +User.authorized_contributors.first.username+
  #
  # @return [ActiveRecord::Relation] the users who have signed the cla
  #
  def self.authorized_contributors
    User.includes(:accounts).
      joins('LEFT JOIN icla_signatures ON icla_signatures.user_id = users.id').
      joins('LEFT JOIN ccla_signatures ON ccla_signatures.user_id = users.id').
      joins('LEFT JOIN contributors ON contributors.user_id = users.id').
      where('accounts.provider = ?', 'chef_oauth2').
      where('icla_signatures.id IS NOT NULL OR ccla_signatures.id
            IS NOT NULL OR contributors.id IS NOT NULL').
      order('accounts.username').
      distinct
  end

  #
  # Find a user from a GitHub login. If there is no user with that GitHub login,
  # return a new user.
  #
  # @param [String] github_login The GitHub login/username to find the user by
  #
  # @return [User] The user with that GitHub login. If none exists, return a new
  #                user.
  #
  def self.find_by_github_login(github_login)
    account = Account.for('github').with_username(github_login).first

    account.try(:user) || User.new
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

  private

  #
  # Subscribe new users to all emails by default
  #
  def default_email_preferences
    EmailPreference.default_set_for_user(self) if email_preferences.blank?
  end
end
