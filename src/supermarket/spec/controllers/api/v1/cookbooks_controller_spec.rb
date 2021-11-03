require "spec_helper"

describe Api::V1::CookbooksController do
  let!(:clive) { create(:user) }
  let!(:slow_cooking) do
    create(:cookbook, name: "slow_cooking", web_download_count: 12, api_download_count: 15)
  end

  let!(:sashimi) do
    create(:cookbook, name: "sashimi", web_download_count: 11, api_download_count: 14, owner: clive)
  end

  it_behaves_like "an API v1 controller"

  describe "#index" do

    before :each do
      ENV["API_ITEM_LIMIT"] = "0"
    end

    it "orders the cookbooks by their name by default" do
      get :index, format: :json

      cookbook_names = assigns[:cookbooks].map(&:name)

      expect(cookbook_names).to eql(%w{sashimi slow_cooking})
    end

    it "allows ordering by recently updated" do
      slow_cooking.touch
      get :index, params: { order: :recently_updated, format: :json }
      cookbooks = assigns[:cookbooks]
      expect(cookbooks.first).to eql(slow_cooking)
      expect(cookbooks.last).to eql(sashimi)
    end

    it "allows ordering by recently added" do
      get :index, params: { order: :recently_added, format: :json }
      cookbooks = assigns[:cookbooks]
      expect(cookbooks.first).to eql(sashimi)
      expect(cookbooks.last).to eql(slow_cooking)
    end

    it "allows ordering by most downloaded" do
      get :index, params: { order: :most_downloaded, format: :json }
      cookbooks = assigns[:cookbooks]
      expect(cookbooks.first).to eql(slow_cooking)
      expect(cookbooks.last).to eql(sashimi)
    end

    it "allows ordering by most followed" do
      create(:cookbook_follower, cookbook: slow_cooking, user: create(:user))
      create(:cookbook_follower, cookbook: slow_cooking, user: create(:user))
      create(:cookbook_follower, cookbook: sashimi, user: create(:user))

      get :index, params: { order: :most_followed, format: :json }
      cookbooks = assigns[:cookbooks]
      expect(cookbooks.first).to eql(slow_cooking)
      expect(cookbooks.last).to eql(sashimi)
    end

    it "allows filtering cookbooks by owner" do
      get :index, params: { user: clive.username, format: :json }
      cookbooks = assigns[:cookbooks]
      expect(cookbooks.size).to eql(1)
      expect(cookbooks.first).to eql(sashimi)
    end

    it "allows filtering cookbooks by platform" do
      create(:debian_cookbook_version, cookbook: sashimi)

      get :index, params: { platforms: "debian", format: :json }
      cookbooks = assigns[:cookbooks]
      expect(cookbooks.size).to eql(1)
      expect(cookbooks.first).to eql(sashimi)
    end

    it "uses the start param to offset the cookbooks sent to the view" do
      get :index, params: { start: 1, format: :json }

      cookbook_names = assigns[:cookbooks].map(&:name)

      expect(cookbook_names).to eql(["slow_cooking"])
    end

    it "passes the start param to the view" do
      get :index, params: { start: 1, format: :json }

      expect(assigns[:start]).to eql(1)
    end

    it "defaults the start param to 0" do
      get :index, format: :json

      expect(assigns[:start]).to eql(0)
    end

    it "uses the items param to limit the cookbooks sent to the view" do
      get :index, params: { items: 1, format: :json }

      cookbook_names = assigns[:cookbooks].map(&:name)

      expect(cookbook_names).to eql(["sashimi"])
    end

    it "defaults the items param to 10" do
      get :index, format: :json

      expect(assigns[:items]).to eql(10)
    end

    it "limits the number of items to the configured limit" do
      allow(subject).to receive(:item_limit).and_return(100)
      get :index, params: { items: 101, format: :json }

      expect(assigns[:items]).to eql(100)
    end

    it "handles the start and items param" do
      get :index, params: { items: 1, start: 1, format: :json }

      cookbook_names = assigns[:cookbooks].map(&:name)

      expect(cookbook_names).to eql(["slow_cooking"])
    end

    it "passes the total number of cookbooks to the view" do
      get :index, format: :json

      expect(assigns[:total]).to eql(2)
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
    context "when a cookbook exists" do
      before do
        create(
          :cookbook_version,
          cookbook: sashimi,
          version: "1.1.0",
          license: "MIT"
        )

        create(
          :cookbook_version,
          cookbook: sashimi,
          version: "2.1.0",
          license: "MIT"
        )
      end

      it "responds with a 200" do
        get :show, params: { cookbook: "sashimi", format: :json }

        expect(response.status.to_i).to eql(200)
      end

      it "sends the cookbook to the view" do
        get :show, params: { cookbook: "sashimi", format: :json }

        expect(assigns[:cookbook]).to eql(sashimi)
      end

      it "sends the cookbook_versions_urls to the view" do
        get :show, params: { cookbook: "sashimi", format: :json }

        expect(assigns[:cookbook_versions_urls]).to include("http://test.host/api/v1/cookbooks/sashimi/versions/2.1.0")
        expect(assigns[:cookbook_versions_urls]).to include("http://test.host/api/v1/cookbooks/sashimi/versions/1.1.0")
      end
    end

    context "when a cookbook does not exist" do
      it "responds with a 404" do
        get :show, params: { cookbook: "mamimi", format: :json }

        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe "#contingent" do
    context "when a cookbook exists" do
      before do
        create(
          :cookbook_version,
          cookbook: sashimi,
          version: "1.1.0",
          license: "MIT"
        )

        v2 = create(
          :cookbook_version,
          cookbook: sashimi,
          version: "2.1.0",
          license: "MIT"
        )

        create(:cookbook_dependency, cookbook: slow_cooking, cookbook_version: v2)
      end

      it "responds with a 200" do
        get :contingent, params: { cookbook: "sashimi", format: :json }

        expect(response.status.to_i).to eql(200)
      end

      it "sends the cookbook to the view" do
        get :contingent, params: { cookbook: "sashimi", format: :json }

        expect(assigns[:cookbook]).to eql(sashimi)
      end

      it "sends the contingents to the view" do
        get :contingent, params: { cookbook: "slow_cooking", format: :json }

        contingents = assigns[:contingents]
        expect(contingents.first.cookbook_version.cookbook).to eql(sashimi)
      end
    end

    context "when a cookbook does not exist" do
      it "responds with a 404" do
        get :show, params: { cookbook: "mamimi", format: :json }

        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe "#search" do
    let!(:redis) { create(:cookbook, name: "redis") }
    let!(:redis_2) { create(:cookbook, name: "redis-2") }
    let!(:postgres) { create(:cookbook, name: "postgres") }

    it "responds with a 200" do
      get :search, format: :json

      expect(response.status.to_i).to eql(200)
    end

    it "sends cookbook search result to the view" do
      get :search, params: { q: "redis", format: :json }

      expect(assigns[:results]).to include(redis)
    end

    it "sends the total number of cookbooks present in system to the view" do
      get :search, params: { q: "redis", format: :json }

      expect(assigns[:total]).to eql(5)
    end

    it "searches based on the query" do
      get :search, params: { q: "postgres", format: :json }

      expect(assigns[:results]).to include(postgres)
      expect(assigns[:results]).to_not include(redis)
    end

    it "sends start param to the view if it is present" do
      get :search, params: { q: "redis", start: "1", format: :json }

      expect(assigns[:start]).to eql(1)
    end

    it "defaults the start param to 0 if it is not present" do
      get :search, params: { q: "redis", format: :json }

      expect(assigns[:start]).to eql(0)
    end

    it "handles the start param" do
      get :search, params: { q: "redis", start: 1, format: :json }

      cookbook_names = assigns[:results].map(&:name)

      expect(cookbook_names).to eql(["redis-2"])
    end

    it "handles the items param" do
      6.times do |index|
        create(:cookbook, name: "jam#{index}")
      end

      get :search, params: { q: "jam", items: 5, format: :json }
      cookbooks = assigns[:results]
      expect(cookbooks.count(:all)).to eql 5
    end
  end
end
