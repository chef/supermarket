class Tool < ApplicationRecord
  include PgSearch::Model

  ALLOWED_TYPES = %w{knife_plugin ohai_plugin chef_tool chef_infra_handler kitchen_driver powershell_module dsc_resource compliance_profile}.freeze

  self.inheritance_column = nil

  # Associations
  # --------------------
  belongs_to :owner, class_name: "User", foreign_key: :user_id, inverse_of: :tools
  has_one :chef_account, through: :owner
  has_many :collaborators, as: :resourceable, inverse_of: :resourceable, dependent: :destroy
  has_many :collaborator_users, through: :collaborators, source: :user
  has_many :direct_collaborators, -> { where(group_id: nil) }, as: :resourceable, class_name: "Collaborator", inverse_of: :resourceable
  has_many :direct_collaborator_users, through: :direct_collaborators, source: :user
  has_many :group_resources, as: :resourceable, inverse_of: :resourceable, dependent: :destroy

  # Validations
  # --------------------
  validates :name, uniqueness: { case_sensitive: false }, presence: true # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :lowercase_name, presence: true, uniqueness: true
  validates :type, inclusion: { in: ALLOWED_TYPES }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }, format: /\A[\w_-]+\z/i
  validates :source_url, url: { allow_blank: true }

  # Search
  # --------------------
  pg_search_scope(
    :search,
    against: {
      name: "A",
      description: "C",
    },
    associated_against: {
      chef_account: { username: "B" },
    },
    using: {
      tsearch: { dictionary: "english", only: [:username, :description], prefix: true },
      trigram: { only: [:name] },
    },
    ranked_by: ":trigram + (0.5 * :tsearch)",
    order_within_rank: "tools.name"
  )

  # Callbacks
  # --------------------
  before_validation :copy_name_to_lowercase_name
  before_validation :strip_name_whitespace
  before_validation :ensure_slug
  before_validation :lowercase_slug

  #
  # Query tools by case-insensitive name.
  #
  # @param name [String, Array<String>] a single name, or a collection of names
  #
  # @example
  #   Tool.with_name('dingus').first
  #     #<Tool name: "dingus"...>
  #   Tool.with_name(['dingus', 'thingy']).to_a
  #     [#<Tool name: "dingus"...>, #<Tool name: "thingy"...>]
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
      "recently_added" => "id DESC",
    }.fetch(ordering, "name ASC"))
  }

  scope :paginated_with_owner, lambda { |opts = {}|
    includes(owner: :chef_account)
      .ordered_by(opts.fetch(:order, "name ASC"))
      .limit(opts.fetch(:limit, 10))
      .offset(opts.fetch(:start, 0))
  }

  #
  # The username of this tools's owner
  #
  # @return [String]
  #
  def maintainer
    owner.username
  end

  #
  # Returns other tools owned by the owner of this tool
  #
  # @return [ActiveRecord::Relation<Tool>] an ActiveRecord::Relation of Tools
  #
  def others_from_this_owner
    Tool.where("user_id = ? AND id <> ?", user_id, id).order(:name)
  end

  #
  # Returns the slug of the +Tool+.
  #
  # @return [String] the slug of the +Tool+
  #
  def to_param
    slug
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

  #
  # Mostly for purposes of uniqueness validation, names shouldn't
  # contain leading or trailing whitespace.
  #
  def strip_name_whitespace
    self.name = name.to_s.strip
  end

  #
  # Slugs should always be lowercase.
  #
  def lowercase_slug
    self.slug = slug.to_s.downcase
  end

  #
  # Ensure we always have a slug
  #
  def ensure_slug
    self.slug = name.parameterize if slug.blank?
  end
end
