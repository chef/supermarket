require "spec_helper"

describe "cookbooks/index.atom.builder" do
  let(:template_path) { "cookbooks/index" }
  let(:render_formats) { [:atom] }
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
      cookbook_versions_count: 0,
      cookbook_versions: [
        create(:cookbook_version, description: "test cookbook"),
      ]
    )
  end

  describe "some cookbooks" do
    before do
      assign(:cookbooks, [test_cookbook, test_cookbook2])
      render template: template_path, formats: render_formats
    end

    it "displays the feed title" do
      expect(xml_body["feed"]["title"]).to eql("Cookbooks")
    end

    it "displays when the feed was updated" do
      expect(Date.parse(xml_body["feed"]["updated"])).to_not be_nil
    end

    it "displays cookbook entries" do
      expect(xml_body["feed"]["entry"].count).to eql(2)
    end

    it "displays information about a cookbook" do
      cookbook = xml_body["feed"]["entry"].first

      expect(cookbook["title"]).to eql("test")
      expect(cookbook["author"]["name"]).to eql(test_cookbook.owner.username)
      expect(cookbook["author"]["uri"]).to eql(user_url(test_cookbook.owner))
      expect(cookbook["content"]).to match(/this cookbook is so rad/)
      expect(cookbook["content"]).to match(/we added so much stuff/)
      expect(cookbook["link"]["href"]).to eql("http://test.host/cookbooks/test")
    end
  end

  describe "no cookbooks" do
    before do
      assign(:cookbooks, [])
      render template: template_path, formats: render_formats
    end

    it "still works if @cookbooks is empty" do
      expect do
        expect(Date.parse(xml_body["feed"]["updated"])).to_not be_nil
      end.to_not raise_error
    end
  end
end
