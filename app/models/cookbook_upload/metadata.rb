require 'virtus'

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
  class Metadata
    include Virtus.value_object(strict: true)

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

    values do
      attribute :name, String, default: ''
      attribute :version, String, default: ''
      attribute :description, String, default: ''
      attribute :license, String, default: ''
      attribute :platforms, Hash[String => String]
      attribute :dependencies, Hash[String => String]
      attribute :source_url, String, default: ''
      attribute :issues_url, String, default: ''
      attribute :privacy, Boolean, default: false
      attribute :chef_version, String, default: ''
      attribute :ohai_version, String, default: ''
    end
  end
end
