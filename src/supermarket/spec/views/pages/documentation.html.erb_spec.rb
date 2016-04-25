require "spec_helper"

describe "pages/documentation.html.erb" do
  context "page with links" do
    it "refers to the title of the documentation page" do
      render
      title_text = "Documentation, Guides, Tutorials"
      expect(rendered).to have_selector('h2', text: title_text)
    end

    it "displays links" do
      render
      expect(rendered).to have_selector('a[href]')
    end
  end
end
