class CookbookUpload
  class Document < SchemaDefiner::SymbolizeStruct
    attribute :contents, SchemaDefiner::Types::Coercible::String.default(nil)
    attribute :extension, SchemaDefiner::Types::Coercible::String.default("", shared: true)
  end
end
