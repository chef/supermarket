class User < ActiveRecord::Base
  include Authorizable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Associations
  # --------------------
  has_many :accounts
  has_many :icla_signatures
  has_many :ccla_signatures
  has_many :contributors
  has_many :organizations, through: :contributors

  # Validations
  # --------------------
  validates_presence_of :first_name
  validates_presence_of :last_name

  #
  # The commit author identities who have signed a CLA
  #
  # @return [Array<Curry::CommitAuthor>]
  #
  def verified_commit_author_identities
    accounts.for(:github).map do |account|
      Curry::CommitAuthor.with_login(account.username).where(signed_cla: true)
    end.flatten
  end

  #
  # The commit author identities who have not signed a CLA
  #
  # @return [Array<Curry::CommitAuthor>]
  #
  def unverified_commit_author_identities
    accounts.for(:github).map do |account|
      Curry::CommitAuthor.with_login(account.username).where(signed_cla: false)
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
    !icla_signatures.empty?
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

  # Determine if the current user signed the Corporate Contributor License
  # Agreement.
  #
  # @todo Expand this functionality to search for the most recently active
  #       CCLA and return some sort of history instead.
  #
  # @return [Boolean]
  #
  def signed_ccla?
    !ccla_signatures.empty?
  end

  #
  # Determine if the current user signed any CLAs.
  #
  # @return [Boolean]
  #
  def signed_cla?
    signed_icla? || signed_ccla?
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
  #   user.account_from_oauth?(request.env['omniauth.auth'])
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
  # The user's Chef ID username
  #
  # @return [String] the username for that Chef ID
  # @return [nil] if the user has unlinked their Chef ID
  #
  def username
    accounts.for('chef_oauth2').first.try(:username)
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
    account = Account.for('github').where(username: github_login).first

    account.try(:user) || User.new
  end
end
