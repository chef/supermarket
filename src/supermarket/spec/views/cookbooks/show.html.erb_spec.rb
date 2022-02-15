require "spec_helper"

describe "cookbooks/show.html.erb" do

  context "renders detail page for a cookbook" do
    let(:template_path) { "cookbooks/show" }
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

    let!(:collaborator) { create(:cookbook_collaborator, resourceable: cookbook, user: create(:user)) }

    before(:each) do
      allow(view).to receive(:policy) do |record|
        Pundit.policy(current_user, record)
      end

      assign(:cookbook, cookbook)
      assign(:collaborators, cookbook.collaborators)
      assign(:latest_version, cookbook.latest_cookbook_version)
      assign(:cookbook_versions, cookbook.sorted_cookbook_versions)
      assign(:supported_platforms, cookbook.supported_platforms)
      assign(:public_metric_results, cookbook_version.metric_results.open.sorted_by_name)
      assign(:admin_metric_results, cookbook_version.metric_results.admin_only.sorted_by_name)
      assign(:current_user, current_user)

      allow(view).to receive(:cookbook).and_return(cookbook)
      allow(view).to receive(:latest_version).and_return(cookbook.latest_cookbook_version)
      allow(view).to receive(:cookbook_versions).and_return(cookbook.sorted_cookbook_versions)
      allow(view).to receive(:supported_platforms).and_return(cookbook.supported_platforms)
      allow(view).to receive(:collaborators).and_return(cookbook.collaborators)
      allow(view).to receive(:current_user).and_return(current_user)
    end

    it "has license text rendered" do
      render template: template_path
      license_id = "MIT"
      expect(rendered).to have_selector("p", text: license_id)
    end

    it "has license url text" do
      render template: template_path
      expect(rendered).to have_selector(:css, 'a[href="https://spdx.org/licenses/MIT.json"]' )
    end

    it "has Test Kitchen text correct" do
      render template: template_path
      test_kitchen_text = cookbook.cookbook_deprecation_reason
      expect(rendered).to have_selector("textarea", text: test_kitchen_text)
    end

    it "has policyfile, berkshelf and knife tabs rendered" do
      render template: template_path
      expect(rendered).to have_selector("div", id: "policyfile")
      expect(rendered).to have_selector("div", id: "berkshelf")
      expect(rendered).to have_selector("div", id: "knife")
    end
  end

end
