require "spec_helper"

describe "cookbooks/directory.html.erb" do
  let(:template_path) { "cookbooks/directory" }

  before do
    assign(:featured_cookbooks, [])
    assign(:recently_updated_cookbooks, [])
    assign(:most_downloaded_cookbooks, [])
    assign(:most_followed_cookbooks, [])
  end

  it "has Test Kitchen text correct" do
    render template: template_path
    test_kitchen_text = "Test Kitchen documentation"
    expect(rendered).to have_selector("a[href]", text: test_kitchen_text)
  end

  it "has workstation link pointing to correct url" do
    render template: template_path
    expect(rendered).to have_link("Chef Workstation", href: "https://www.chef.io/downloads/tools/workstation")
  end

  it_behaves_like "community stats", "cookbooks/directory"
end
