class RunQualityMetrics
  def self.all_the_latest
    return [:error, I18n.t("fieri.not_enabled")] unless Feature.active? :fieri

    cookbook_version_ids = CookbookVersion.where('
      cookbook_versions.created_at = (
        SELECT MAX(latest.created_at)
        FROM cookbook_versions AS latest
        WHERE latest.cookbook_id = cookbook_versions.cookbook_id
      )
    ').ids

    cookbook_version_ids.each do |cookbook_version_id|
      FieriNotifyWorker.perform_async cookbook_version_id
    end

    [:ok, I18n.t("fieri.scheduled.multiple", count: cookbook_version_ids.length)]
  end

  def self.on_latest(cookbook_name)
    return [:error, I18n.t("fieri.not_enabled")] unless Feature.active? :fieri

    cookbook = Cookbook.find_by name: cookbook_name
    return [:error, I18n.t("cookbook.not_found", name: cookbook_name)] unless cookbook

    latest_cookbook_version = cookbook.latest_cookbook_version
    FieriNotifyWorker.perform_async latest_cookbook_version.id

    [:ok, I18n.t("fieri.scheduled.single", name: cookbook.name, version: latest_cookbook_version.version)]
  end

  def self.on_version(cookbook_name, version)
    return [:error, I18n.t("fieri.not_enabled")] unless Feature.active? :fieri

    cookbook = Cookbook.find_by name: cookbook_name
    return [:error, I18n.t("cookbook.not_found", name: cookbook_name)] unless cookbook

    cookbook_version = cookbook.cookbook_versions.find_by version: version
    return [:error, I18n.t("cookbook.version_not_found", name: cookbook_name, version: version)] unless cookbook_version

    FieriNotifyWorker.perform_async cookbook_version.id

    [:ok, I18n.t("fieri.scheduled.single", name: cookbook.name, version: cookbook_version.version)]
  end
end
