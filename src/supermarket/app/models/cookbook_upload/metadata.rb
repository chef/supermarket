class CookbookUpload
  #
  # Acts as a schema for a cookbook's metadata.json. It only provides fields
  # for the metadata attributes we use, while remaining flexible enough to
  # handle any metadata hash.
  #
  # @note It is a value object which means that two +Metadata+ objects are
  #   considered to be identical if they have the same attribute values
  #
  # @example
  #   metadata = CookbookUpload::Metadata.new(name: "Apache")
  #   metadata.name #=> "Apache"
  #
  class Metadata < SchemaDefiner::SymbolizeStruct
    #
    # @!attribute [r] name
    #   @return [String] The cookbook name
    #

    #
    # @!attribute [r] version
    #   @return [String] The cookbook version
    #

    #
    # @!attribute [r] description
    #   @return [String] The cookbook description
    #

    #
    # @!attribute [r] license
    #   @return [String] The cookbook license
    #

    #
    # @!attribute [r] platforms
    #   @return [Hash<String,String>] The platforms supported by the cookbook
    #
    #   @example
    #     metadata.platforms == { 'ubuntu' => '>= 0.0.0' }
    #

    #
    # @!attribute [r] dependencies
    #   @return [Hash<String,String>] The cookbook dependencies
    #
    #   @example
    #     metadata.dependencies == { 'apt' => '~> 0.0.2' }
    #

    #
    # @!attribute [r] source_url
    #   @return [String] The cookbook source url
    #

    #
    # @!attribute [r] issues_url
    #   @return [String] The cookbook issues url
    #

    #
    # @!attribute [r] privacy
    #   @return [Boolean] Whether or not this cookbook is private
    #

    #
    # @!attribute [r] chef_versions
    #   @return [JSON] Chef Versions this cookbook's version will work with
    #   i.e. [[12.1,12.2],[11.2,12.3]]
    #   inner array elements are joined by "&&" while the outer array is joined by "||" operators.
    #   So a cookbook version with the example would work with Chef Version 12.1 AND 12.2 OR Chef Version 11.2 AND 12.3
    #   See https://github.com/chef/supermarket/issues/1201 for more details

    # @!attribute [r] ohai_versions
    #   @return [JSON] Ohai Versions this cookbook's version will work with
    #   i.e. [[8.0.1,8.0.2],[8.1.1,8.1.2]]
    #   inner array elements are joined by "&&" while the outer array is joined by "||" operators.
    #   So a cookbook version with the example would work with Ohai Version 8.0.1 AND 8.0.2 OR Chef Version 8.1.1 AND 8.1.2

    attribute :name, SchemaDefiner::Types::Coercible::String.default("", shared: true)
    attribute :version, SchemaDefiner::Types::Coercible::String.default("", shared: true)
    attribute :description, SchemaDefiner::Types::Coercible::String.default("", shared: true)
    attribute :license, SchemaDefiner::Types::Coercible::String.default("", shared: true)
    attribute :platforms, SchemaDefiner::Types::Coercible::Hash.default({}, shared: true)
    attribute :dependencies, SchemaDefiner::Types::Coercible::Hash.default({}, shared: true)
    attribute :source_url, SchemaDefiner::Types::Coercible::String.default("", shared: true)
    attribute :issues_url, SchemaDefiner::Types::Coercible::String.default("", shared: true)
    attribute :privacy, SchemaDefiner::Types::Bool.default(false)
    attribute :chef_versions, SchemaDefiner::Types::JSON::Array.default([], shared: true)
    attribute :ohai_versions, SchemaDefiner::Types::JSON::Array.default([], shared: true)
  end
end
