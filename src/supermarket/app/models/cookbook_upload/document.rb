class CookbookUpload
  class Document < SchemaDefiner::SymbolizeStruct
    
    #
    # @!attribute [r] contents
    #   @return [String] The text of the Document
    #

    #
    # @!attribute [r] extension
    #   @return [String] The README extension
    #

    attribute :contents, SchemaDefiner::Types::Coercible::String.default(nil)
    attribute :extension, SchemaDefiner::Types::Coercible::String.default("", shared: true)
  end
end
