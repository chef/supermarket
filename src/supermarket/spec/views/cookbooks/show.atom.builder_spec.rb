require "spec_helper"

describe "cookbooks/show.atom.builder" do
  let(:template_path) { "cookbooks/show" }
  let(:render_formats) { [:atom] }
  let!(:kiwi_0_1_0) do
    create(
      :cookbook_version,
      version: "0.1.0",
      license: "MIT"
    )
  end

  let!(:kiwi_0_2_0) do
    create(
      :cookbook_version,
      version: "0.2.0",
      license: "MIT",
      changelog: "we added so much stuff!",
      changelog_extension: "md"
    )
  end

  let!(:kiwi) do
    create(
      :cookbook,
      name: "Kiwi",
      cookbook_versions_count: 0,
      cookbook_versions: [kiwi_0_2_0, kiwi_0_1_0]
    )
  end

  before do
    assign(:cookbook_versions, kiwi.cookbook_versions)
    assign(:cookbook, kiwi)
    render template: template_path, formats: render_formats
  end

  it "displays the feed title" do
    expect(xml_body["feed"]["title"]).to eql("Kiwi versions")
  end

  it "displays when the feed was updated" do
    expect(Date.parse(xml_body["feed"]["updated"])).to_not be_nil
  end

  it "displays cookbook version entries" do
    expect(xml_body["feed"]["entry"].count).to eql(2)
  end

  it "displays information about a cookbook" do
    cookbook = xml_body["feed"]["entry"].first

    expect(cookbook["title"]).to eql("Kiwi - v0.2.0")
    expect(cookbook["content"]).to match(Regexp.new(kiwi_0_2_0.description))
    expect(cookbook["content"]).to match(/we added so much stuff!/)
    expect(cookbook["author"]["name"]).to eql(kiwi.owner.username)
    expect(cookbook["author"]["uri"]).to eql(user_url(kiwi.owner))
  end
end
