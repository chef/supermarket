require "spec_helper"
describe "cookbook_mailer/cookbook_deprecated_email.html.erb" do
	context "renders mailer page" do
		let!(:current_user) { create(:user, first_name: "test_user") }
		let!(:cookbook) {
      create(
        :cookbook,
        name: "test_cookbook",
        user_id: current_user.id
      )
    }
    let!(:replacement_cookbook) { create(:cookbook, name: "test_cookbook1") }
		before(:each) do
			cookbook.deprecate(replacement_cookbook, "test descreption")
			assign(:cookbook, cookbook)
			assign(:replacement_cookbook, replacement_cookbook)
			assign(:email_preference, current_user.email_preference_for("Cookbook deprecated"))
		end

		it "has cookbook name rendered" do
      render
      expect(rendered).to have_selector("p", text: cookbook.name)
    end

    it "has cookbook deprecation reason rendered" do
      render
      expect(rendered).to have_selector("p", text: cookbook.cookbook_deprecation_reason)
    end
	end
end