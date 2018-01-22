Paperclip.interpolates(:compatible_id) do |attachment, _style|
  attachment.instance.try(:legacy_id) || attachment.instance.id
end

# Paperclip has a few remote-fetcher adapters for retrieving attachments from some other place.
# We don't want to use them. Remove these adapters, if they are present in the adapter registry.
remote_adapters = [Paperclip::UriAdapter, Paperclip::HttpUrlProxyAdapter, Paperclip::DataUriAdapter]
Paperclip.io_adapters
         .registered_handlers
         .delete_if do |_block, handler_class|
           remote_adapters.include?(handler_class)
         end

':class/:attachment/:compatible_id/:style/:basename.:extension'.tap do |path|
  if Supermarket::S3ConfigAudit.use_s3?(ENV)
    if ENV['S3_PATH'].present?
      path = "#{ENV['S3_PATH']}/#{path}"
    end

    options = {
      storage: 's3',
      s3_credentials: {
        bucket: ENV['S3_BUCKET'],
        access_key_id: ENV['S3_ACCESS_KEY_ID'],
        secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
      },
      path: path,
      bucket: ENV['S3_BUCKET'],
      s3_protocol: ENV['PROTOCOL'],
      s3_region: ENV['S3_REGION']
    }

    if ENV['S3_PRIVATE_OBJECTS'] == 'true'
      options = options.merge(
        s3_permissions: :private
      )
    end

    options = if ENV['CDN_URL'].present?
                options.merge(
                  url: ':s3_alias_url',
                  s3_host_alias: ENV['CDN_URL']
                )
              else
                options.merge(
                  url: ENV['S3_DOMAIN_STYLE']
                )
              end

    ::Paperclip::Attachment.default_options.update(options)
  else
    ::Paperclip::Attachment.default_options.update(
      storage: :filesystem,
      path: ':rails_root/public:url',
      url: "/system/#{path}"
    )
  end
end
