Rabl.configure do |config|
  # Commented values are the defaults
  config.cache_all_output = true
  config.cache_sources = !Rails.env.development?
  # config.cache_engine = Rabl::CacheEngine.new # Defaults to Rails cache
  config.perform_caching = true
  # config.escape_all_output = false
  # config.json_engine = JSON
  # config.msgpack_engine = ::MessagePack
  # config.bson_engine = ::BSON
  # config.plist_engine = ::Plist::Emit
  config.include_json_root = false
  # config.include_msgpack_root = true
  # config.include_bson_root = true
  # config.include_plist_root = true
  # config.include_xml_root  = false
  config.include_child_root = false
  # config.enable_json_callbacks = false
  # config.xml_options = { :dasherize  => true, :skip_types => false }
  # config.view_paths = []
  # config.raise_on_missing_attribute = false
  # config.replace_nil_values_with_empty_strings = false
end
