require 'spec_helper'
require 'vcr_helper'

describe SitemapRefreshWorker do
  around(:each) do |example|
    VCR.use_cassette('sitemap_refresh_worker', record: :once) do
      example.run
    end
  end

  it 'refreshes the sitemap' do
    sitemap_file_path = SitemapGenerator::Sitemap.public_path.to_s + SitemapGenerator::Sitemap.namer.to_s

    # delete the current sitemap if it exists
    if File.exist?(sitemap_file_path)
      File.delete(sitemap_file_path)
    end

    SitemapRefreshWorker.new.perform
    expect(File.exist?(sitemap_file_path)).to be true
  end
end
