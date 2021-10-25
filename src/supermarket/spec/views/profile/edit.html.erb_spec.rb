require "spec_helper"

describe "profile/edit.html.erb" do

  context "page with github enterprise account content" do

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
      content = "Linking your account lets other cookbook shoppers find you on GitHub Enterprise for feedback, collaboration, and kudos. The link requests access only to your GitHub Enterprise account's public information."
      expect(rendered).to have_selector("p", text: content)
    end

    it "should have Connect GitHub Account button text" do
      render
      expect(rendered).to have_selector("a", text: "Connect GitHub Enterprise Account")
    end

    it "should have Connect GitHub Account button title" do
      render
      expect(rendered).to have_selector("a[title='Connect with GitHub Enterprise Account']")
    end
  end

  context "page with github account content" do

    let(:user) { create(:user) }

    before do
      allow(view).to receive(:policy) do |record|
        Pundit.policy(user, record)
      end
      allow(view).to receive(:current_user).and_return(user)
      assign(:user, user)
      ENV["GITHUB_ENTERPRISE_URL"] = ""
      ENV["GITHUB_URL"] = "https://github.com"
    end

    it "should have GitHub content on edit profile page" do
      render
      content = "Linking your account lets other cookbook shoppers find you on GitHub for feedback, collaboration, and kudos. The link requests access only to your GitHub account's public information."
      expect(rendered).to have_selector("p", text: content)
    end

    it "should have Connect GitHub Account button text" do
      render
      expect(rendered).to have_selector("a", text: "Connect GitHub Account")
    end

    it "should have Connect GitHub Account button title" do
      render
      expect(rendered).to have_selector("a[title='Connect with GitHub Account']")
    end
  end
end
