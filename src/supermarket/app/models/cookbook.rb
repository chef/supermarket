require "chef/version_class"

class Cookbook < ApplicationRecord
  include PgSearch::Model
  include Badgeable
  extend Badgeable::ClassMethods

  #
  # Query cookbooks by case-insensitive name.
  #
  # @param name [String, Array<String>] a single name, or a collection of names
  #
  # @example
  #   Cookbook.with_name('redis').first
  #     #<Cookbook name: "redis"...>
  #   Cookbook.with_name(['redis', 'apache2']).to_a
  #     [#<Cookbook name: "redis"...>, #<Cookbook name: "apache2"...>]
  #
  # @todo: query and index by +LOWER(name)+ when ruby schema dumps support such
  #   a thing.
  #
  scope :with_name, lambda { |names|
    lowercase_names = Array(names).map { |name| name.to_s.downcase }

    where(lowercase_name: lowercase_names)
  }

  ORDER_OPTIONS = {
    "recently_updated" => Arel.sql("cookbooks.deprecated, cookbooks.updated_at DESC"),
    "recently_added" => Arel.sql("cookbooks.deprecated, cookbooks.id DESC"),
    "most_downloaded" => Arel.sql("cookbooks.deprecated, (cookbooks.web_download_count + cookbooks.api_download_count) DESC, cookbooks.id ASC"),
    "most_followed" => Arel.sql("cookbooks.deprecated, cookbook_followers_count DESC, cookbooks.id ASC"),
    "by_name" => Arel.sql("cookbooks.deprecated, cookbooks.name ASC"),
  }.freeze

  scope :ordered_by, lambda { |option|
    ordering = ORDER_OPTIONS.fetch(option, ORDER_OPTIONS["by_name"] )
    reorder(ordering)
  }

  scope :order_by_latest_upload_date, lambda {
    joins(:cookbook_versions)
      .select("cookbooks.*", "MAX(cookbook_versions.created_at) AS latest_upload")
      .group("cookbooks.id")
      .order("latest_upload DESC")
  }

  scope :owned_by, lambda { |username|
    joins(owner: :chef_account).where("accounts.username = ?", username)
  }

  scope :paginated_with_owner_and_versions, lambda { |opts = {}|
    includes(:cookbook_versions, owner: :chef_account)
      .ordered_by(opts.fetch(:order, "name ASC"))
      .limit(opts.fetch(:limit, 10))
      .offset(opts.fetch(:start, 0))
  }

  scope :featured, -> { where(featured: true) }

  scope :filter_platforms, lambda { |platforms|
    joins(cookbook_versions: :supported_platforms)
      .where("supported_platforms.name IN (?)", platforms).distinct
      .select("cookbooks.*", "(cookbooks.web_download_count + cookbooks.api_download_count)")
  }

  scope :filter_badges, lambda { |badges|
    with_badges badges
  }

  # Search
  # --------------------
  pg_search_scope(
    :search,
    against: {
      name: "A",
    },
    associated_against: {
      chef_account: { username: "B" },
      cookbook_versions: { description: "C" },
    },
    using: {
      tsearch: { dictionary: "english", only: [:username, :description], prefix: true },
      trigram: { only: [:name] },
    },
    ranked_by: ":trigram + (0.5 * :tsearch)",
    order_within_rank: "cookbooks.name"
  )

  # Callbacks
  # --------------------
  before_validation :copy_name_to_lowercase_name

  # Associations
  # --------------------
  has_many :cookbook_versions, dependent: :destroy
  has_many :cookbook_followers # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :followers, through: :cookbook_followers, source: :user
  belongs_to :category, optional: true
  belongs_to :owner, class_name: "User", foreign_key: :user_id, inverse_of: :owned_cookbooks
  has_one :chef_account, through: :owner
  belongs_to :replacement, class_name: "Cookbook", inverse_of: :replaces, optional: true
  has_many :replaces, class_name: "Cookbook", foreign_key: :replacement_id, inverse_of: :replacement, dependent: :nullify
  has_many :collaborators, as: :resourceable, inverse_of: :resourceable # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :collaborator_users, through: :collaborators, source: :user
  has_many :direct_collaborators, -> { where(group_id: nil) }, as: :resourceable, class_name: "Collaborator", inverse_of: :resourceable
  has_many :direct_collaborator_users, through: :direct_collaborators, source: :user
  has_many :group_resources, as: :resourceable, inverse_of: :resourceable, dependent: :destroy

  # Delegations
  # --------------------
  delegate :description, to: :latest_cookbook_version
  delegate :supported_platforms, to: :latest_cookbook_version
  delegate :cookbook_dependencies, to: :latest_cookbook_version

  # Validations
  # --------------------
  validates :name, presence: true, uniqueness: { case_sensitive: false }, format: /\A[\w_-]+\z/i # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :lowercase_name, presence: true, uniqueness: true
  validates :cookbook_versions, presence: true
  validates :source_url, url: { allow_blank: true }
  validates :issues_url, url: { allow_blank: true }

  #
  # The total number of times a cookbook has been downloaded from Supermarket
  #
  # @return [Fixnum]
  #
  def self.total_download_count
    sum(:api_download_count) + sum(:web_download_count)
  end

  #
  # Sorts cookbook versions according to their semantic version
  #
  # @return [Array<CookbookVersion>] the sorted CookbookVersion records
  #
  def sorted_cookbook_versions
    @sorted_cookbook_versions ||= cookbook_versions.sort_by { |v| Chef::Version.new(v.version) }.reverse
  end

  #
  # Transfers ownership of this cookbook to someone else. If the user id passed
  # in represents someone that is already a collaborator on this cookbook, or
  # if the User initiating this transfer is an admin, then we just assign the
  # new owner and move on. If they're not already a collaborator, then we send
  # them an email asking if they want ownership of this cookbook. This
  # prevents abuse of people assigning random owners without getting permission.
  #
  # @param initiator [User] the User initiating the transfer
  # @param recipient [User] the User to assign ownership to
  #
  # @return [String] a key representing a message to display to the user
  #

  def transfer_ownership(initiator, recipient, add_owner_as_collaborator = false)
    original_owner = owner

    if initiator.is?(:admin) || collaborator_users.include?(recipient)
      update(user_id: recipient.id)

      if add_owner_as_collaborator
        create_new_collaborator(original_owner)
      end

      delete_old_collaborator(recipient)
      "cookbook.ownership_transfer.done"
    else
      transfer_request = OwnershipTransferRequest.create(
        sender: initiator,
        recipient: recipient,
        add_owner_as_collaborator: add_owner_as_collaborator,
        cookbook: self
      )
      CookbookMailer.delay.transfer_ownership_email(transfer_request)
      "cookbook.ownership_transfer.email_sent"
    end
  end

  #
  # The most recent CookbookVersion, based on the semantic version number
  #
  # @return [CookbookVersion] the most recent CookbookVersion
  #
  def latest_cookbook_version
    @latest_cookbook_version ||= sorted_cookbook_versions.first
  end

  #
  # Return all of the cookbook errors as well as full error messages for any of
  # the CookbookVersions
  #
  # @return [Array<String>] all the error messages
  #
  def seriously_all_of_the_errors
    messages = errors.full_messages.reject { |e| e == "Cookbook versions is invalid" }

    cookbook_versions.each do |version|
      almost_everything = version.errors.full_messages.reject { |x| x =~ /Tarball can not be/ }
      messages += almost_everything
    end

    messages
  end

  #
  # Returns the name of the +Cookbook+ parameterized.
  #
  # @return [String] the name of the +Cookbook+ parameterized
  #
  def to_param
    name.parameterize
  end

  #
  # Return the specified +CookbookVersion+. Raises an
  # +ActiveRecord::RecordNotFound+ if the version does not exist. Versions can
  # be specified with either underscores or dots.
  #
  # @example
  #   cookbook.get_version!("1_0_0")
  #   cookbook.get_version!("1.0.0")
  #   cookbook.get_version!("latest")
  #
  # @param version [String] the version of the Cookbook to find. Pass in
  #                         'latest' to return the latest version of the
  #                         cookbook.
  #
  # @return [CookbookVersion] the +CookbookVersion+ with the version specified
  #
  def get_version!(version)
    version.tr!("_", ".")

    if version == "latest"
      latest_cookbook_version
    else
      cookbook_versions.find_by!(version: version)
    end
  end

  #
  # Saves a new version of the cookbook as specified by the given metadata, tarball
  # and readme. If it's a new cookbook the user specified becomes the owner.
  #
  # @raise [ActiveRecord::RecordInvalid] if the new version fails validation
  # @raise [ActiveRecord::RecordNotUnique] if the new version is a duplicate of
  #   an existing version for this cookbook
  #
  # @return [CookbookVersion] the Cookbook Version that was published
  #
  # @param params [CookbookUpload::Parameters] the upload parameters
  #
  def publish_version!(params, user)
    metadata = params.metadata

    if metadata.privacy &&
       ENV["ENFORCE_PRIVACY"].present? &&
       ENV["ENFORCE_PRIVACY"] == "true"
      errors.add(:base, I18n.t("api.error_messages.privacy_violation"))
      raise ActiveRecord::RecordInvalid.new(self)
    end

    tarball = params.tarball
    readme = params.readme
    changelog = params.changelog

    dependency_names = metadata.dependencies.keys
    existing_cookbooks = Cookbook.with_name(dependency_names)

    cookbook_version = nil

    transaction do
      cookbook_version = cookbook_versions.build(
        cookbook: self,
        user: user,
        description: metadata.description,
        license: metadata.license,
        version: metadata.version,
        tarball: tarball,
        readme: readme.contents,
        readme_extension: readme.extension,
        changelog: changelog.contents,
        changelog_extension: changelog.extension,
        chef_versions: metadata.chef_versions,
        ohai_versions: metadata.ohai_versions
      )

      self.updated_at = Time.current

      [:source_url, :issues_url].each do |url|
        url_val = metadata.send(url)

        if url_val.present?
          self[url] = url_val
        end
      end

      self.privacy = metadata.privacy
      save!

      metadata.platforms.each do |name, version_constraint|
        cookbook_version.add_supported_platform(name, version_constraint)
      end

      metadata.dependencies.each do |name, version_constraint|
        cookbook_version.cookbook_dependencies.create!(
          name: name,
          version_constraint: version_constraint,
          cookbook: existing_cookbooks.find { |c| c.name == name }
        )
      end
    end

    cookbook_version
  end

  #
  # Returns true if the user passed follows the cookbook.
  #
  # @return [TrueClass]
  #
  # @param user [User]
  #
  def followed_by?(user)
    cookbook_followers.where(user: user).any?
  end

  #
  # Returns all of the CookbookDependency records that are contingent upon this one.
  #
  # @return [Array<CookbookDependency>]
  #
  def contingents
    CookbookDependency
      .includes(cookbook_version: :cookbook)
      .where(cookbook_id: id)
      .sort_by do |cd|
        [
          cd.cookbook_version.cookbook.name,
          Chef::Version.new(cd.cookbook_version.version),
        ]
      end
  end

  #
  # The username of this cookbook's owner
  #
  # @return [String]
  #
  def maintainer
    owner.username
  end

  #
  # The total number of times this cookbook has been downloaded
  #
  # @return [Fixnum]
  #
  def download_count
    web_download_count + api_download_count
  end

  #
  # Sets the cookbook's deprecated attribute to true, assigns the replacement
  # cookbook if specified and saves the cookbook.
  #
  # A cookbook can only be replaced with a cookbook that is not deprecated.
  #
  # @param replacement_cookbook_name [String] the name of the cookbook to
  #   succeed this cookbook once deprecated
  #
  # @return [Boolean] whether or not the cookbook was successfully deprecated
  #   and  saved
  #
  def deprecate(replacement_cookbook_name = "")
    replacement_cookbook = Cookbook.find_by name: replacement_cookbook_name

    if replacement_cookbook.present? && replacement_cookbook.deprecated?
      errors.add(:base, I18n.t("cookbook.deprecate_with_deprecated_failure"))
      return false
    end

    self.deprecated = true
    self.replacement = replacement_cookbook if replacement_cookbook.present?
    save
  end

  #
  # Searches for cookbooks based on the +query+ parameter. Returns results that
  # are elgible for deprecation (not deprecated and not this cookbook).
  #
  # @param query [String] the search term
  #
  # @return [Array<Cookbook> the +Cookbook+ search results
  #
  def deprecate_search(query)
    Cookbook.search(query).where(deprecated: false).where.not(id: id)
  end

  private

  #
  # Populates the +lowercase_name+ attribute with the lowercase +name+
  #
  # This exists until Rails schema dumping supports Posgres's expression
  # indices, which would allow us to create an index on LOWER(name). To do that
  # now, we'd have to use the raw SQL schema dumping functionality, which is
  # less-than ideal
  #
  def copy_name_to_lowercase_name
    self.lowercase_name = name.to_s.downcase
  end

  def create_new_collaborator(initiator)
    collaborators.find_or_create_by!(user_id: initiator.id)
  end

  def delete_old_collaborator(user)
    if collaborator_users.include?(user)
      collaborator = collaborators.find_by(
        user_id: user.id,
        resourceable: self,
        group_id: nil
      )
      # Do not destroy collaborator is collaborator does not exist
      # OR if the collaborator is associated with a group
      collaborator&.destroy
    end
  end
end
