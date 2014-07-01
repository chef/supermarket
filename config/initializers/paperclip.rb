Paperclip.interpolates(:compatible_id) do |attachment, _style|
  attachment.instance.legacy_id || attachment.instance.id
end

':class/:attachment/:compatible_id/:style/:basename.:extension'.tap do |path|
  configured = %w(S3_BUCKET S3_ACCESS_KEY_ID S3_SECRET_ACCESS_KEY).all? do |key|
    ENV[key].present?
  end

  if configured
    ::Paperclip::Attachment.default_options.update(
      storage: 's3',
      s3_credentials: {
        bucket: ENV['S3_BUCKET'],
        access_key_id: ENV['S3_ACCESS_KEY_ID'],
        secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
      },
      url: ':s3_path_url',
      path: path,
      bucket: ENV['S3_BUCKET'],
      s3_protocol: ENV['PROTOCOL']
    )
  else
    ::Paperclip::Attachment.default_options.update(
      storage: :filesystem,
      path: ':rails_root/public:url',
      url: "/system/#{path}"
    )
  end
end
