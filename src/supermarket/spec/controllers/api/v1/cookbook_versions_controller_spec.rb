require "spec_helper"

describe Api::V1::CookbookVersionsController do
  describe "#show" do
    let!(:redis) { create(:cookbook, name: "redis") }

    let!(:redis_0_1_2) do
      create(:cookbook_version, cookbook: redis, version: "0.1.2")
    end

    let!(:redis_1_0_0) do
      create(:cookbook_version, cookbook: redis, version: "1.0.0")
    end

    it "responds with a 200" do
      get :show, params: { cookbook: "redis", version: "latest", format: :json }

      expect(response.status.to_i).to eql(200)
    end

    it "sends the cookbook to the view" do
      get :show, params: { cookbook: "redis", version: "latest", format: :json }

      expect(assigns[:cookbook]).to eql(redis)
    end

    it "sends the cookbook version to the view" do
      get :show, params: { cookbook: "redis", version: "1.0.0", format: :json }

      expect(assigns[:cookbook_version]).to eql(redis_1_0_0)
    end

    it "includes the cookbook version's metric results" do
      qm = create(:cookstyle_metric)
      metric_result = create(:metric_result,
                             cookbook_version: redis_1_0_0,
                             quality_metric: qm)

      get :show, params: { cookbook: "redis", version: "1.0.0", format: :json }

      expect(assigns[:cookbook_version_metrics]).to include(metric_result)
    end

    it "handles the latest version of a cookbook" do
      latest_version = redis.latest_cookbook_version
      get :show, params: { cookbook: "redis", version: "latest", format: :json }

      expect(assigns[:cookbook_version]).to eql(latest_version)
    end

    it "handles specific versions of a cookbook" do
      get :show, params: { cookbook: "redis", version: "0_1_2", format: :json }

      expect(assigns[:cookbook_version]).to eql(redis_0_1_2)
    end

    it "404s if a cookbook version does not exist" do
      get :show, params: { cookbook: "redis", version: "4_0_2", format: :json }

      expect(response.status.to_i).to eql(404)
    end
  end

  describe "#download" do
    let(:cookbook) { create(:cookbook) }
    let(:version) { create(:cookbook_version, cookbook: cookbook) }

    it "302s to the cookbook version file URL" do
      get :download, params: { cookbook: cookbook.name, version: version.to_param, format: :json }

      expect(response).to redirect_to(version.cookbook_artifact_url)
      expect(response.status.to_i).to eql(302)
    end

    it "logs the web download count for the cookbook version" do
      expect do
        get :download, params: { cookbook: cookbook.name, version: version.to_param, format: :json }
      end.to change { version.reload.api_download_count }.by(1)
    end

    it "logs the web download count for the cookbook" do
      expect do
        get :download, params: { cookbook: cookbook.name, version: version.to_param, format: :json }
      end.to change { cookbook.reload.api_download_count }.by(1)
    end

    it "404s when the cookbook does not exist" do
      get :download, params: { cookbook: "snarfle", version: "100.1.1", format: :json }

      expect(response.status.to_i).to eql(404)
    end

    it "404s when the cookbook version does not exist" do
      get :download, params: { cookbook: cookbook.name, version: "100.1.1", format: :json }

      expect(response.status.to_i).to eql(404)
    end
  end
end
