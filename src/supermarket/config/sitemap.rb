# Set the host name for URL creation
if Rails.env.production?
  SitemapGenerator::Sitemap.default_host = Supermarket::Host.full_url
else
  SitemapGenerator::Sitemap.default_host = 'http://www.example.com'
end

# Disable sitemap task status output when using SitemapGenerator in-code
SitemapGenerator.verbose = false

SitemapGenerator::Sitemap.create do
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.

  add(cookbooks_directory_path)

  Cookbook.find_each do |cookbook|
    add(cookbook_path(cookbook), lastmod: cookbook.updated_at, priority: 0.8)
  end

  CookbookVersion.includes(:cookbook).find_each do |cookbook_version|
    add(cookbook_version_path(cookbook_version.cookbook, cookbook_version), lastmod: cookbook_version.updated_at)
  end

  User.includes(:chef_account).find_each do |user|
    add(user_path(user), lastmod: user.updated_at)
  end

  add(icla_signatures_path)
  add(ccla_signatures_path)
end
