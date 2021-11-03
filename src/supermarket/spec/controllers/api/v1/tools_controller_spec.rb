require "spec_helper"

describe Api::V1::ToolsController do
  it_behaves_like "an API v1 controller"

  describe "#index" do
    let!(:metal) do
      create(:tool, name: "metal")
    end

    let!(:berkshelf) do
      create(:tool, name: "berkshelf")
    end

    before :each do
      ENV["API_ITEM_LIMIT"] = "0"
    end

    it "responds with a 200" do
      get :index, format: :json

      expect(response.status.to_i).to eql(200)
    end

    it "sends the tools to view" do
      get :index, format: :json

      expect(assigns[:tools]).to be_present
    end

    it "sends the total tools count to view" do
      get :index, format: :json

      expect(assigns[:total]).to be_present
    end

    it "sends start to view" do
      get :index, params: { start: 4, format: :json }

      expect(assigns[:start]).to eql(4)
    end

    it "sends items to view" do
      get :index, format: :json

      expect(assigns[:items]).to be_present
    end

    it "sends order to view" do
      get :index, format: :json

      expect(assigns[:order]).to be_present
    end

    it "orders the tools by their name by default" do
      get :index, format: :json

      tool_names = assigns[:tools].map(&:name)

      expect(tool_names).to eql(%w{berkshelf metal})
    end

    it "allows ordering by recently added" do
      get :index, params: { order: :recently_added, format: :json }
      tools = assigns[:tools]
      expect(tools.first).to eql(berkshelf)
      expect(tools.last).to eql(metal)
    end

    it "uses the start param to offset the tools sent to the view" do
      get :index, params: { start: 1, format: :json }

      tool_names = assigns[:tools].map(&:name)

      expect(tool_names).to eql(["metal"])
    end

    it "uses the items param to limit the tools sent to the view" do
      get :index, params: { items: 1, format: :json }

      tool_names = assigns[:tools].map(&:name)

      expect(tool_names).to eql(["berkshelf"])
    end

    it "handles the start and items param" do
      get :index, params: { items: 1, start: 1, format: :json }

      tools_names = assigns[:tools].map(&:name)

      expect(tools_names).to eql(["metal"])
    end

    it "defaults the items param to 10" do
      get :index, format: :json

      expect(assigns[:items]).to eql(10)
    end

    it "defaults the start param to 0" do
      get :index, format: :json

      expect(assigns[:start]).to eql(0)
    end

    it "limits the number of items to the configured limit" do
      allow(subject).to receive(:item_limit).and_return(100)
      get :index, params: { items: 101, format: :json }

      expect(assigns[:items]).to eql(100)
    end

    it "returns a 400 if start is negative" do
      get :index, params: { start: -1, format: :json }

      expect(response.status).to eql(400)
    end

    it "returns a 400 if items is negative" do
      get :index, params: { items: -1, format: :json }

      expect(response.status).to eql(400)
    end
  end

  describe "#show" do
    context "when a tool exists" do
      let!(:berkshelf_tool) { create(:tool, name: "berkshelf") }

      it "responds with a 200" do
        get :show, params: { tool: berkshelf_tool.slug, format: :json }

        expect(response.status.to_i).to eql(200)
      end

      it "sends the tool to the view" do
        get :show, params: { tool: berkshelf_tool.slug, format: :json }

        expect(assigns[:tool]).to eql(berkshelf_tool)
      end
    end

    context "when a tool does not exist" do
      it "responds with a 404" do
        get :show, params: { tool: "trololol", format: :json }

        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe "#search" do
    let!(:knife_tool) { create(:tool, name: "knife-tool") }
    let!(:berks_api) { create(:tool, name: "berks-api") }
    let!(:berkshelf) { create(:tool, name: "berkshelf") }
    let!(:wut_wut) { create(:tool, name: "wut-wut") }

    it "responds with a 200" do
      get :search, format: :json

      expect(response.status.to_i).to eql(200)
    end

    it "sends tool search result to the view" do
      get :search, params: { q: "knife-tool", format: :json }

      expect(assigns[:results]).to include(knife_tool)
    end

    it "sends the total number of search results to the view" do
      get :search, params: { q: "berks", format: :json }

      expect(assigns[:total]).to eql(2)
    end

    it "searches based on the query" do
      get :search, params: { q: "knife-tool", format: :json }

      expect(assigns[:results]).to include(knife_tool)
      expect(assigns[:results]).to_not include(wut_wut)
    end

    it "sends start param to the view if it is present" do
      get :search, params: { q: "berks", start: "1", format: :json }

      expect(assigns[:start]).to eql(1)
    end

    it "defaults the start param to 0 if it is not present" do
      get :search, params: { q: "berks", format: :json }

      expect(assigns[:start]).to eql(0)
    end

    it "handles the start param" do
      get :search, params: { q: "berks", start: 1, format: :json }

      tool_names = assigns[:results].map(&:name)

      expect(tool_names).to eql(["berkshelf"])
    end

    it "handles the items param" do
      6.times do |index|
        create(:tool, name: "jam#{index}")
      end

      get :search, params: { q: "jam", items: 5, format: :json }
      tools = assigns[:results]
      expect(tools.count(:all)).to eql 5
    end
  end
end
