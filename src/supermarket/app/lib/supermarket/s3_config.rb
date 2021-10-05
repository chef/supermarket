module Supermarket
  class S3Config
    class IncompleteConfig < StandardError; end

    REQUIRED_S3_VARS = %w{S3_BUCKET S3_REGION}.freeze
    REQUIRED_S3_STATIC_CREDS_VARS = %w{S3_ACCESS_KEY_ID S3_SECRET_ACCESS_KEY}.freeze

    attr_accessor :default_path, :environment

    def initialize(path, environment)
      @default_path = path
      @environment = environment
    end

    def self.use_s3?(environment)
      any_s3_settings = REQUIRED_S3_VARS.any? { |key| environment.key?(key) }
      all_s3_settings = REQUIRED_S3_VARS.all? { |key| environment[key].present? }

      if any_s3_settings && !all_s3_settings
        raise IncompleteConfig.new "Got some, but not all, of the required S3 configs. You provided: #{REQUIRED_S3_VARS & environment.keys}. You must provide #{REQUIRED_S3_VARS} to configure cookbook storage in an S3 bucket."
      end
      return true if all_s3_settings

      false
    end

    def to_paperclip_options
      options = {
        storage: "s3",
        path: default_path,
        bucket: environment["S3_BUCKET"],
        s3_protocol: environment["PROTOCOL"],
        s3_credentials: s3_credentials,
        url: environment["S3_DOMAIN_STYLE"] || ":s3_domain_url",
      }

      if environment["S3_PATH"].present?
        options[:path] = "#{environment["S3_PATH"]}/#{default_path}"
      end

      if environment["S3_PRIVATE_OBJECTS"] == "true"
        options[:s3_permissions] = :private
      end

      if environment["S3_ENCRYPTION"].present?
        options[:s3_server_side_encryption] = environment["S3_ENCRYPTION"].to_sym
      end

      if environment["CDN_URL"].present?
        options[:url] = ":s3_alias_url"
        options[:s3_host_alias] = environment["CDN_URL"]
      end

      if environment["S3_ENDPOINT"].present?
        endpoint = environment["S3_ENDPOINT"]
        options[:s3_options] = { endpoint: endpoint }
        options[:s3_host_name] = endpoint.sub(%r{^https?://}, "")
        Aws.config.update(
          endpoint: endpoint,
          force_path_style: true
        )
      end

      options
    end

    private

    def s3_credentials
      s3_credentials = {
        bucket: environment["S3_BUCKET"],
        s3_region: environment["S3_REGION"],
      }

      # If static creds are present in config - use them
      if use_s3_with_static_creds?
        s3_credentials = s3_credentials.merge(
          access_key_id: environment["S3_ACCESS_KEY_ID"],
          secret_access_key: environment["S3_SECRET_ACCESS_KEY"]
        )
      end

      s3_credentials
    end

    def use_s3_with_static_creds?
      any_s3_creds = REQUIRED_S3_STATIC_CREDS_VARS.any? { |key| environment.key?(key) }
      all_s3_creds = REQUIRED_S3_STATIC_CREDS_VARS.all? { |key| environment[key].present? }

      # Handle situation when one of S3_ACCESS_KEY_ID or S3_SECRET_ACCESS_KEY is missing while other one is present
      if any_s3_creds && !all_s3_creds
        raise IncompleteConfig.new "Got some, but not all, of AWS user credentials. To access an S3 bucket with IAM user credentials, provide #{REQUIRED_S3_STATIC_CREDS_VARS}. To use an IAM role, do not set these."
      end
      return true if all_s3_creds

      false
    end
  end
end
