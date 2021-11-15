module SchemaDefiner
  class SymbolizeStruct < Dry::Struct
    # This will convert all attributes to symbol type
    # when assigning to a class that inherits from this class
    transform_keys(&:to_sym)
  end
end