require 'spec_helper'

describe SitemapRefreshWorker do
  it 'refreshes the sitemap' do
    sitemap_file_path = './public/sitemap.xml.gz'
    sitemap_file_path = SitemapGenerator::Sitemap.public_path.to_s + SitemapGenerator::Sitemap.namer.to_s

    # delete the current sitemap if it exists
    if File.exists?(sitemap_file_path)
      File.delete(sitemap_file_path)
    end

    SitemapRefreshWorker.new.perform
    expect(File.exists?(sitemap_file_path)).to be_true
  end
end
