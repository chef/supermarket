require 'virtus'

class CookbookUpload
  class Readme
    include Virtus.value_object

    #
    # @!attribute [r] contents
    #   @return [String] The text of the README
    #

    #
    # @!attribute [r] extension
    #   @return [String] The README extension
    #

    values do
      attribute :contents, String
      attribute :extension, String
    end
  end
end
