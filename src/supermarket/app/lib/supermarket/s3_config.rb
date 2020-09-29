module Supermarket
  module S3ConfigAudit
    class IncompleteConfig < StandardError; end

    REQUIRED_S3_VARS = %w{S3_BUCKET S3_REGION}.freeze
    REQUIRED_S3_STATIC_CREDS_VARS = %w{S3_ACCESS_KEY_ID S3_SECRET_ACCESS_KEY}.freeze

    def self.use_s3?(environment)
      any_s3_settings = REQUIRED_S3_VARS.any? { |key| environment.key?(key) }
      all_s3_settings = REQUIRED_S3_VARS.all? { |key| environment[key].present? }

      if any_s3_settings && !all_s3_settings
        raise IncompleteConfig.new "Got some, but not all, of the required S3 configs. Must provide #{REQUIRED_S3_VARS} to configure cookbook storage in an S3 bucket."
      end
      return true if all_s3_settings

      false
    end

    def self.use_s3_with_static_creds?(environment)
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
