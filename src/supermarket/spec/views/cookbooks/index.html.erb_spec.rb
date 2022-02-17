require "spec_helper"

describe "cookbooks/index.html.erb" do
  let(:template_path) { "cookbooks/index" }
  let!(:current_user) { create(:user, first_name: "test_user") }

  let(:cookbook_version) {
    create(
      :cookbook_version,
      version: "0.2.0",
      license: "MIT",
      changelog: "we added so much stuff!",
      changelog_extension: "md"
    )
  }

  let(:test_cookbook) {
    create(
      :cookbook,
      name: "test_cookbook",
      cookbook_versions_count: 0,
      user_id: current_user.id,
      cookbook_versions: [cookbook_version]
    )
  }

  let!(:test_cookbook2) do
    create(
      :cookbook,
      name: "test_cookbook_2",
      cookbook_versions_count: 0,
      cookbook_versions: [
        create(:cookbook_version, description: "test cookbook"),
      ]
    )
  end

  before(:each) do
    assign(:cookbooks, [test_cookbook, test_cookbook2])
    assign(:current_params, {})
    assign(:number_of_cookbooks, 2)
    assign(:paginate, 1)
    assign(:current_user, current_user)

    allow(view).to receive(:cookbooks).and_return([test_cookbook, test_cookbook2])
    allow(view).to receive(:current_params).and_return({})
    allow(view).to receive(:number_of_cookbooks).and_return(2)
    allow(view).to receive(:paginate).and_return(1)
    allow(view).to receive(:current_user).and_return(current_user)
  end

  it "has span cookbooks text" do
    render template: template_path
    expect(rendered).to have_selector("span", text: "2 Cookbooks")
  end

  it "has RSS text correct" do
    render template: template_path
    expect(rendered).to have_selector("a[href]", text: "RSS")
  end
end
