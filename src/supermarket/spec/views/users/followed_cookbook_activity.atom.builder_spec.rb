require "spec_helper"

describe "users/followed_cookbook_activity.atom.builder" do
  let!(:test_cookbook_5_0) do
    create(
      :cookbook_version,
      version: "5.0",
      description: "this cookbook is so rad",
      changelog: "we added so much stuff!",
      changelog_extension: "md"
    )
  end

  let!(:test_cookbook) do
    create(
      :cookbook,
      name: "test",
      cookbook_versions_count: 0,
      cookbook_versions: [test_cookbook_5_0]
    )
  end

  let!(:test_cookbook2) do
    create(
      :cookbook,
      name: "test-2",
      cookbook_versions: [
        create(:cookbook_version, description: "test cookbook"),
      ],
      cookbook_versions_count: 0
    )
  end

  before { assign(:user, double(User, username: "johndoe")) }

  describe "some activity" do
    before do
      assign(
        :followed_cookbook_activity,
        [test_cookbook.cookbook_versions.first, test_cookbook2.cookbook_versions.first]
      )

      render template: "users/followed_cookbook_activity"
    end

    it "displays the feed title" do
      expect(xml_body["feed"]["title"]).to eql("johndoe's Followed Cookbook Activity")
    end

    it "displays when the feed was updated" do
      expect(Date.parse(xml_body["feed"]["updated"])).to_not be_nil
    end

    it "displays followed cookbook activity entries" do
      expect(xml_body["feed"]["entry"].count).to eql(2)
    end

    it "displays information about cookbook activity" do
      activity = xml_body["feed"]["entry"].first

      expect(activity["title"]).to eql("#{test_cookbook_5_0.user.name}: #{test_cookbook_5_0.name} v#{test_cookbook_5_0.version} released by #{test_cookbook_5_0.published_by.name}")
      expect(activity["content"]).to match(/this cookbook is so rad/)
      expect(activity["content"]).to match(/we added so much stuff/)
      expect(activity["author"]["name"]).to eql(test_cookbook_5_0.user.name)
      expect(activity["author"]["uri"]).to eql(user_url(test_cookbook_5_0.user))
      expect(activity["link"]["href"])
        .to eql(cookbook_version_url(test_cookbook, test_cookbook.cookbook_versions.first.version))
    end
  end

  describe "no activity" do
    before do
      assign(:followed_cookbook_activity, [])
      render template: "users/followed_cookbook_activity"
    end

    it "still works if @followed_cookbook_activity is empty" do
      expect do
        expect(Date.parse(xml_body["feed"]["updated"])).to_not be_nil
      end.to_not raise_error
    end
  end
end
