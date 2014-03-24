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
    # @!attribute [r] maintainer
    #   @return [String] The cookbook maintainer's name(s)
    #

    #
    # @!attribute [r] license
    #   @return [String] The cookbook license
    #

    #
    # @!attribute [r] platforms
    #   @return [String] The platforms supported by the cookbook
    #
    #   @example
    #     metadata.platforms == { 'ubuntu' => '>= 0.0.0' }
    #

    values do
      attribute :name, String, default: ''
      attribute :version, String, default: ''
      attribute :description, String, default: ''
      attribute :maintainer, String, default: ''
      attribute :license, String, default: ''
      attribute :platforms, Hash[String => String]
    end
  end
end
