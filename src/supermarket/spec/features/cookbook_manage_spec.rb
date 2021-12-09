require "spec_helper"

describe "updating a cookbook's issues and source urls" do
  let(:user) { create(:user) }
  before { sign_in user }

  it "saves the source and issues urls" do
    cookbook = create(:cookbook, owner: user)

    visit cookbook_path(cookbook)

    within ".sidebar" do
      follow_relation "edit-cookbook-urls"
      fill_in "cookbook[source_url]", with: "http://example.com/source"
      fill_in "cookbook[issues_url]", with: "http://example.com/tissues"

      within ".cookbook-details" do
        submit_form
      end
    end

    expect(find(".source-url")[:href]).to eql("http://example.com/source")
    expect(find(".issues-url")[:href]).to eql("http://example.com/tissues")
  end

  it "displays an error message when invalid urls are entered" do
    cookbook = create(:cookbook, owner: user)

    visit cookbook_path(cookbook)

    within ".sidebar" do
      follow_relation "edit-cookbook-urls"
      fill_in "cookbook[source_url]", with: "example"
      fill_in "cookbook[source_url]", with: "example"
    end

    within ".cookbook-details" do
      expect(find(".edit_cookbook").all(".error").count).to eql(2)
    end
  end
end
