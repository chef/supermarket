require Rails.root.join("app/lib/supermarket/s3_config")
Paperclip.interpolates(:compatible_id) do |attachment, _style|
  attachment.instance.try(:legacy_id) || attachment.instance.id
end

# Paperclip has a few remote-fetcher adapters for retrieving attachments from some other place.
# We don't want to use them. Remove these adapters, if they are present in the adapter registry.
remote_adapters = [Paperclip::UriAdapter, Paperclip::HttpUrlProxyAdapter, Paperclip::DataUriAdapter]
Paperclip
  .io_adapters
  .registered_handlers
  .delete_if do |_block, handler_class|
    remote_adapters.include?(handler_class)
  end

":class/:attachment/:compatible_id/:style/:basename.:extension".tap do |path|
  if Supermarket::S3Config.use_s3?(ENV)
    options = Supermarket::S3Config.new(path, ENV).to_paperclip_options
    ::Paperclip::Attachment.default_options.update(options)
  else
    ::Paperclip::Attachment.default_options.update(
      storage: :filesystem,
      path: ":rails_root/public:url",
      url: "/system/#{path}"
    )
  end
end
