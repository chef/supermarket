class SpdxLicenseUpdateWorker
  include Sidekiq::Worker

  def perform(json_data, cookbook_version_id)
    cookbook_version = CookbookVersion.find(cookbook_version_id.to_i)
    spdx_record = json_data.select { |record| record["licenseId"] == cookbook_version.license }
    if spdx_record.present?
      cookbook_version.spdx_license_url = spdx_record[0]["detailsUrl"].to_s
      cookbook_version.save!
    else
      logger.error("Unable to find SPDX license for cookbook #{cookbook_version.cookbook.name} For license #{cookbook_version.license}") unless Rails.env.test?
    end
  end
end

