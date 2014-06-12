require 'supermarket/import'

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
      migration_metrics = {
        collaborators: {
          supermarket: imported(CookbookCollaborator).count,
          community_site: Supermarket::Import::Collaboration.ids.count
        },
        cookbooks: {
          supermarket: imported(Cookbook).count,
          community_site: Supermarket::Import::Cookbook.ids.count
        },
        cookbook_versions: {
          supermarket: imported(CookbookVersion).where(dependencies_imported: true).count,
          community_site: Supermarket::Import::CookbookVersion.ids.count
        },
        deprecated_cookbooks: {
          supermarket: imported(Cookbook).where(deprecated: true).count,
          community_site: Supermarket::Import::DeprecatedCookbook.ids.count
        },
        followings: {
          supermarket: imported(CookbookFollower).count,
          community_site: Supermarket::Import::Following.ids.count
        },
        users: {
          supermarket: imported(User).count,
          community_site: Supermarket::Import::User.ids.count
        },
        platforms: {
          supermarket: imported(CookbookVersionPlatform).count,
          community_site: Supermarket::Import::PlatformVersion.ids.count
        }
      }

      @metrics[:migration] = migration_metrics
    end
  end

  private

  def imported(model)
    model.where('legacy_id IS NOT ?', nil)
  end
end
