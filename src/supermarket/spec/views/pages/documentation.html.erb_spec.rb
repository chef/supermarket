require "spec_helper"

describe "pages/documentation.html.erb" do

  context "with 2 pages" do
    it "displays links" do
      render

      expect(rendered).to have_link 'Supermarket Docs', href: 'https://docs.chef.io/supermarket.html'
    end
  end
end