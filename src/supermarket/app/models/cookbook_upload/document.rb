class CookbookUpload
  class Document < Dry::Struct

    attribute? :contents, SchemaDefiner::Types::String
    attribute :extension, SchemaDefiner::Types::String.default("".freeze)
  end
end
