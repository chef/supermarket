class UpdateSpdxLicenseUrl

  def self.all_latest_cookbook_versions
    cookbook_version_ids = CookbookVersion.where('
      cookbook_versions.created_at = (
        SELECT MAX(latest.created_at)
        FROM cookbook_versions AS latest
        WHERE latest.cookbook_id = cookbook_versions.cookbook_id
      )
    ').pluck(:id)

    cookbook_version_ids.each do |cookbook_version_id|
      SpdxLicenseUpdateWorker.perform_async(FetchSpdxLicenseJson.spdx_license_json, cookbook_version_id)
    end

    [:ok, I18n.t("spdx_license.scheduled.multiple", count: cookbook_version_ids.length)]
  end

  def self.on_latest(cookbook_name)
    cookbook = Cookbook.find_by name: cookbook_name
    return [:error, I18n.t("cookbook.not_found", name: cookbook_name)] unless cookbook

    cookbook_version = cookbook.latest_cookbook_version
    return [:error, I18n.t("cookbook.version_not_found", name: cookbook_name, version: version)] unless cookbook_version

    SpdxLicenseUpdateWorker.perform_async(FetchSpdxLicenseJson.spdx_license_json, cookbook_version.id)

    [:ok, I18n.t("spdx_license.scheduled.latest", name: cookbook.name)]
  end

  def self.on_version(cookbook_name, version)
    cookbook = Cookbook.find_by name: cookbook_name
    return [:error, I18n.t("cookbook.not_found", name: cookbook_name)] unless cookbook

    cookbook_version = cookbook.cookbook_versions.find_by version: version
    return [:error, I18n.t("cookbook.version_not_found", name: cookbook_name, version: version)] unless cookbook_version

    SpdxLicenseUpdateWorker.perform_async(FetchSpdxLicenseJson.spdx_license_json, cookbook_version.id)

    [:ok, I18n.t("spdx_license.scheduled.single", name: cookbook.name, version: cookbook_version.id)]
  end
end
