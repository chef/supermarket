require "spec_helper"

describe "profile/edit.html.erb" do
  context "page with github enterprise profile link" do
    let(:user) { create(:user) }
    before do
      allow(view).to receive(:policy) do |record|
        Pundit.policy(user, record)
      end
      allow(view).to receive(:current_user).and_return(user)
      assign(:user, user)
      ENV["GITHUB_ENTERPRISE_URL"] = "https://example.com"
    end
    it "should have GitHub Enterprise content on edit profile page" do
      render
      content = "Linking your account lets other cookbook shoppers find you on GitHub OR GitHub Enterprise for feedback, collaboration, and kudos. The link requests access only to your GitHub OR GitHub Enterprise account's public information."
      expect(rendered).to have_selector("p", text: content)
    end

     it "should have Connect GitHub Account button title" do
      render
      expect(rendered).to have_selector("a[title='Connect with GitHub OR GitHub Enterprise Account']")
    end
  end
end
