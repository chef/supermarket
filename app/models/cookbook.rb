class Cookbook < ActiveRecord::Base
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

  scope :ordered_by, lambda { |ordering|
    reorder({
      'recently_updated' => 'updated_at DESC',
      'recently_added' => 'id DESC',
      'most_downloaded' => '(web_download_count + api_download_count) DESC, id ASC',
      'most_followed' => 'cookbook_followers_count DESC, id ASC'
    }.fetch(ordering, 'name ASC'))
  }

  scope :owned_by, lambda { |username|
    joins(owner: :chef_account).where('accounts.username = ?', username)
  }

  scope :index, lambda { |opts = {}|
    includes(:cookbook_versions, owner: :chef_account)
    .ordered_by(opts.fetch(:order, 'name ASC'))
    .limit(opts.fetch(:limit, 10))
    .offset(opts.fetch(:start, 0))
  }

  scope :featured, -> { where(featured: true) }

  searchable do
    text :name
    string :name
    integer :id
    boolean :featured
    boolean :deprecated
    time :updated_at
    integer :cookbook_followers_count
    integer(:total_downloads) { |c| c.web_download_count + c.api_download_count }

    text :cookbook_versions do
      cookbook_versions.map { |cookbook_version| cookbook_version.description }
    end

    text :chef_account do
      chef_account.username
    end
  end

  # Callbacks
  # --------------------
  before_validation :copy_name_to_lowercase_name

  # Associations
  # --------------------
  has_many :cookbook_versions, dependent: :destroy
  has_many :cookbook_followers
  has_many :followers, through: :cookbook_followers, source: :user
  belongs_to :category
  belongs_to :owner, class_name: 'User', foreign_key: :user_id
  has_one :chef_account, through: :owner
  belongs_to :replacement, class_name: 'Cookbook', foreign_key: :replacement_id
  has_many :cookbook_collaborators
  has_many :collaborators, through: :cookbook_collaborators, source: :user

  # Delegations
  # --------------------
  delegate :description, to: :latest_cookbook_version

  # Validations
  # --------------------
  validates :name, presence: true, uniqueness: { case_sensitive: false }, format: /\A[\w_-]+\z/i
  validates :lowercase_name, presence: true, uniqueness: true
  validates :cookbook_versions, presence: true
  validates :category, presence: true
  validates :source_url, url: {
    allow_blank: true,
    allow_nil: true
  }
  validates :issues_url, url: {
    allow_blank: true,
    allow_nil: true
  }
  validates :replacement, presence: true, if: :deprecated?

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
    @sorted_cookbook_versions ||= cookbook_versions.sort_by { |v| Semverse::Version.new(v.version) }.reverse
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
    messages = errors.full_messages.reject { |e| e == 'Cookbook versions is invalid' }

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
    version.gsub!('_', '.')

    if version == 'latest'
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
  # @return [TrueClass]
  #
  # @param metadata [CookbookUpload::Metadata] the cookbook metadata
  # @param tarball [File] the cookbook artifact
  # @param readme [File] the cookbook readme
  #
  def publish_version!(metadata, tarball, readme)
    dependency_names = metadata.dependencies.keys
    existing_cookbooks = Cookbook.with_name(dependency_names)

    transaction do
      cookbook_version = cookbook_versions.build(
        cookbook: self,
        description: metadata.description,
        license: metadata.license,
        version: metadata.version,
        tarball: tarball,
        readme: readme.contents,
        readme_extension: readme.extension
      )

      self.updated_at = Time.now
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

    true
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
  # Returns the platforms supported by the latest version of this cookbook.
  #
  # @return [Array<SupportedVersion>]
  #
  def supported_platforms
    latest_cookbook_version.supported_platforms
  end

  #
  # Returns the dependencies of the latest version of this cookbook.
  #
  # @return [Array<CookbookDependency>]
  #
  def cookbook_dependencies
    latest_cookbook_version.cookbook_dependencies
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
  # @param replacement_cookbook [Cookbook] the cookbook to succeed this cookbook
  #   once deprecated
  #
  # @return [Boolean] whether or not the cookbook was successfully deprecated
  #   and  saved
  #
  def deprecate(replacement_cookbook)
    if replacement_cookbook.deprecated?
      errors.add(:base, I18n.t('cookbook.deprecate_with_deprecated_failure'))
      return false
    else
      self.deprecated = true
      self.replacement = replacement_cookbook
      save
    end
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
    Cookbook.search do
      fulltext query
      with :deprecated, false
      without :id, id
    end.results
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
end
