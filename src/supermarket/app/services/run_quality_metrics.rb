class RunQualityMetrics
  def self.all_the_latest
    CookbookVersion.where('
      cookbook_versions.created_at = (
        SELECT MAX(latest.created_at)
        FROM cookbook_versions AS latest
        WHERE latest.cookbook_id = cookbook_versions.cookbook_id
      )
    ').pluck(:id).each do |cookbook_version_id|
      FieriNotifyWorker.perform_async cookbook_version_id
    end
  end

  def self.on_latest(cookbook_name)
    cookbook = Cookbook.find_by_name cookbook_name
    latest_cookbook_version = cookbook.latest_cookbook_version
    FieriNotifyWorker.perform_async latest_cookbook_version.id
  end

  def self.on_version(cookbook_name, version)
    cookbook = Cookbook.find_by_name cookbook_name
    cookbook_version = cookbook.cookbook_versions.find_by_version version
    FieriNotifyWorker.perform_async cookbook_version.id
  end
end
