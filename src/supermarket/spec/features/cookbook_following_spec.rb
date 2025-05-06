require "spec_helper"

describe "cookbook following" do
  before do
    sign_in(create(:user))
    create_list(:cookbook, 2)
  end

  context "from the cookbook partial" do
    before do
      visit "/cookbooks"
      follow_first_relation "follow"
    end

    it "allows a user to follow a cookbook", use_cuprite: true do
      expect(page).to have_xpath("//a[starts-with(@rel, 'unfollow')]")
    end
  end

  context "from the cookbook show view" do
    before do
      visit "/"
      follow_relation "cookbooks"

      within ".recently-updated" do
        follow_first_relation "cookbook"
      end
    end

    it "allows a user to follow a cookbook", use_cuprite: true do
      within ".cookbook_show" do
        follow_relation "follow"
      end

      expect(page).to have_xpath("//a[starts-with(@rel, 'unfollow')]")
    end

    it "allows a user to unfollow a cookbook", use_cuprite: true do
      within ".cookbook_show" do
        follow_relation "follow"
      end

      within ".cookbook_show" do
        follow_relation "unfollow"
      end

      expect(page).to have_xpath("//a[starts-with(@rel, 'follow')]")
    end
  end
end
