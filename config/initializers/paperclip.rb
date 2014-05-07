Paperclip.interpolates(:compatible_id) do |attachment, style|
  attachment.instance.legacy_id || attachment.instance.id
end

':class/:attachment/:compatible_id/:style/:basename.:extension'.tap do |path|
  if Supermarket::Config.s3
    ::Paperclip::Attachment.default_options.update(
      storage: 's3',
      s3_credentials: Supermarket::Config.s3,
      url: ':s3_path_url',
      path: path,
      bucket: Supermarket::Config.s3['bucket']
    )
  else
    ::Paperclip::Attachment.default_options.update(
      storage: :filesystem,
      path: ':rails_root/public:url',
      url: "/system/#{path}"
    )
  end
end
