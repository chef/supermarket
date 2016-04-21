require "spec_helper"

describe "pages/documentation.html.erb" do
  context "page with links" do
    it "displays links" do
      render
      expect(rendered).to have_selector('a[href]')
    end
  end
end