require "spec_helper"

describe "pages/robots.text.erb" do
  let(:template_path) { "pages/robots" }
  include_context "env stashing"

  it "uses the full host" do
    ENV["FQDN"] = "example.com"
    ENV["PORT"] = "80"
    ENV["PROTOCOL"] = "http"

    render template: template_path
    expect(rendered).to match(%r{Sitemap: http://example\.com/sitemap\.xml\.gz})
  end

  it "configures Allow based on environment variables" do
    ENV["ROBOTS_ALLOW"] = "/"
    render template: template_path
    expect(rendered).to match(%r{Allow: /})
  end

  it "configures Disallow based on environment variables" do
    ENV["ROBOTS_DISALLOW"] = "/admin"
    render template: template_path
    expect(rendered).to match(%r{Disallow: /admin})
  end
end
