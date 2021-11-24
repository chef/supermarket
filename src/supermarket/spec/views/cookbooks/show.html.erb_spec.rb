require "spec_helper"
# require_relative "../../../lib/supermarket/authentication.rb"

describe "cookbooks/show.html.erb" do

  context "renders detail page for a cookbook" do
    let!(:current_user) { create(:user, first_name: "Fanny") }

    let(:cookbook_version) {
      create(
        :cookbook_version,
        version: "0.2.0",
        license: "MIT",
        changelog: "we added so much stuff!",
        changelog_extension: "md",
        spdx_license_url: "https://spdx.org/licenses/MIT.json"
      )
    }

    let(:cookbook) {
      create(
        :cookbook,
        name: "Kiwi",
        cookbook_versions_count: 0,
        user_id: current_user.id,
        cookbook_versions: [cookbook_version]
      )
    }


    it "has license text rendered" do
      render
      license_id = "MIT"
      expect(rendered).to have_selector("p", text: license_id)
    end

    it "has license url text" do
      render
      expect(rendered).to have_selector(:css, 'a[href="https://spdx.org/licenses/MIT.json"]' )
    end

    it "has Test Kitchen text correct" do
      render
      test_kitchen_text = cookbook.cookbook_deprecation_reason
      expect(rendered).to have_selector("textarea", text: test_kitchen_text)
    end
  end

end

