require "spec_helper"

describe "pages/welcome.html.erb" do
  let(:template_path) { "pages/welcome" }

  it "has correct text" do
    render template: template_path
    welcome_text = "Welcome to Supermarket. Find, explore and view Chef Infra Cookbooks for all of your ops needs."
    expect(rendered).to have_selector("h2", text: welcome_text)
  end

  it_behaves_like "community stats", "pages/welcome"
end
