require 'supermarket/community_site'

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
      total_users: User.count
    }

    if ENV['COMMUNITY_SITE_DATABASE_URL'].present?
      @metrics.update(
        opscode_community_site_cookbook_versions: Supermarket::CommunitySite::CookbookVersionRecord.count,
        opscode_community_site_cookbooks: Supermarket::CommunitySite::CookbookRecord.count,
        opscode_community_site_follows: Supermarket::CommunitySite::FollowingRecord.count,
        opscode_community_site_users: Supermarket::CommunitySite::UserRecord.count
      )
    end
  end
end
