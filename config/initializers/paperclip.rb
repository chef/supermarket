Paperclip.interpolates(:compatible_id) do |attachment, _style|
  attachment.instance.try(:legacy_id) || attachment.instance.id
end

':class/:attachment/:compatible_id/:style/:basename.:extension'.tap do |path|
  configured = %w(S3_BUCKET S3_ACCESS_KEY_ID S3_SECRET_ACCESS_KEY).all? do |key|
    ENV[key].present?
  end

  if configured
    options = {
      storage: 's3',
      s3_credentials: {
        bucket: ENV['S3_BUCKET'],
        access_key_id: ENV['S3_ACCESS_KEY_ID'],
        secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
      },
      path: path,
      bucket: ENV['S3_BUCKET'],
      s3_protocol: ENV['PROTOCOL']
    }

    if ENV['S3_PRIVATE_URLS'].present?
      options = options.merge(
        s3_permissions: :private
      )
    end

    if ENV['CDN_URL'].present?
      options = options.merge(
        url: ':s3_alias_url',
        s3_host_alias: ENV['CDN_URL']
      )
    else
      options = options.merge(
        url: ':s3_path_url'
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
