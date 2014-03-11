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
    include Virtus.value_object

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

    values do
      attribute :name, String
      attribute :version, String
      attribute :description, String
      attribute :maintainer, String
      attribute :license, String
    end
  end
end
