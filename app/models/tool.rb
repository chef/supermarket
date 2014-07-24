class Tool < ActiveRecord::Base
  ALLOWED_TYPES = %w(knife_plugin ohai_plugin chef_tool)

  self.inheritance_column = nil

  # Associations
  # --------------------
  belongs_to :owner, class_name: 'User', foreign_key: :user_id

  # Validations
  # --------------------
  validates :name, uniqueness: { case_sensitive: false }, presence: true
  validates :type, inclusion: { in: ALLOWED_TYPES }
  validates :source_url, url: {
    allow_blank: true,
    allow_nil: true
  }

  # Callbacks
  # --------------------
  before_validation :copy_name_to_lowercase_name
  before_validation :strip_name_whitespace

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
    Tool.where('user_id = ? AND id <> ?', user_id, id).order(:name)
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
end
