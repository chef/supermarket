class Api::V1::MetricsController < Api::V1Controller
  #
  # GET /api/v1/metrics
  #
  # Various counters
  #
  def show
    @metrics = {
      total_cookbook_downloads: Cookbook.total_download_count,
      total_cookbook_versions: CookbookVersion.count,
      total_cookbooks: Cookbook.count,
      total_follows: CookbookFollower.count,
      total_users: User.count,
      total_hits: { '/universe' => Universe.show_hits }
    }
  end
end
