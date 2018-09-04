require 'sitemap_generator'

#
# Worker that refreshes Supermarket's sitemap once a day at midnight. Uses
# Sidetiq to schedule the job.
#
class SitemapRefreshWorker
  include Sidekiq::Worker

  #
  # Refresh the sitemap and ping search engines using the SitemapGenerator
  # library.
  #
  # Essentially runs the tasks that +rake sitemap:refresh+ runs.
  #
  # @example:
  #   SitemapResfreshWorker.new.perform
  #
  def perform
    SitemapGenerator::Interpreter.run
    SitemapGenerator::Sitemap.ping_search_engines
  end
end
