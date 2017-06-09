module Supermarket
  module S3ConfigAudit
    class IncompleteConfig < StandardError; end

    REQUIRED_S3_VARS = %w[S3_BUCKET S3_ACCESS_KEY_ID S3_SECRET_ACCESS_KEY S3_REGION].freeze

    def self.use_s3?(environment)
      any_s3_settings = REQUIRED_S3_VARS.any? { |key| environment[key].present? }
      all_s3_settings = REQUIRED_S3_VARS.all? { |key| environment[key].present? }

      if any_s3_settings && !all_s3_settings
        raise IncompleteConfig.new "Got some, but not all, of the required S3 configs. Must provide none or all of #{REQUIRED_S3_VARS} to configure cookbook storage in an S3 bucket."
      end
      return true if all_s3_settings
      false
    end
  end
end
