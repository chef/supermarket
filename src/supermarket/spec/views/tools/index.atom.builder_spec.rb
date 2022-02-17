require "spec_helper"

describe "tools/index.atom.builder" do
  let(:template_path) { "tools/index" }
  let(:render_formats) { [:atom] }
  let(:test_tool) do
    create(
      :tool,
      name: "test"
    )
  end

  let(:test_tool2) do
    create(
      :cookbook,
      name: "test-2"
    )
  end

  before do
    assign(:tools, [test_tool, test_tool2])
  end

  it "displays the feed title" do
    render template: template_path, formats: render_formats

    expect(xml_body["feed"]["title"]).to eql("Tools & Plugins")
  end

  it "displays when the feed was updated" do
    render template: template_path, formats: render_formats

    expect(Date.parse(xml_body["feed"]["updated"])).to_not be_nil
  end

  it "displays tool entries" do
    render template: template_path, formats: render_formats

    expect(xml_body["feed"]["entry"].count).to eql(2)
  end

  it "displays information about a tool" do
    render template: template_path, formats: render_formats

    cookbook = xml_body["feed"]["entry"].first

    expect(cookbook["title"]).to eql(test_tool.name)
    expect(cookbook["content"]).to eql(test_tool.description)
    expect(cookbook["link"]["href"]).to eql(tool_url(test_tool))
    expect(cookbook["author"]["name"]).to eql(test_tool.maintainer)
    expect(cookbook["author"]["uri"]).to eql(user_url(test_tool.owner))
  end
end
