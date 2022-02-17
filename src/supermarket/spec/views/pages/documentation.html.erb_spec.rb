require "spec_helper"

describe "pages/documentation.html.erb" do
  let(:template_path) { "pages/documentation" }
  context "page with links" do
    it "refers to the title of the documentation page" do
      render template: template_path
      title_text = "Documentation, Guides, Tutorials"
      expect(rendered).to have_selector("h2", text: title_text)
    end

    it "displays links" do
      render template: template_path
      expect(rendered).to have_selector("a[href]")
    end
  end
end
