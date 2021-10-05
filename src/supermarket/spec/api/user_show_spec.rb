require "spec_helper"

describe "GET /api/v1/users/:user" do
  context "when the user exists" do
    let!(:user) do
      create(
        :user,
        first_name: "Fanny",
        last_name: "McNanny",
        company: "Fanny Pack",
        twitter_username: "fanny",
        slack_username: "fanny",
        chef_account: create(
          :account,
          provider: "chef_oauth2",
          username: "fanny"
        ),
        create_chef_account: false
      )
    end

    let!(:user_signature) do
      {
        "username" => "fanny",
        "name" => "Fanny McNanny",
        "company" => "Fanny Pack",
        "twitter" => "fanny",
        "slack" => "fanny",
        "github" => ["fanny"],
        "cookbooks" => {
          "owns" => {
            "macand" => "http://www.example.com/api/v1/cookbooks/macand",
            "redis-test" => "http://www.example.com/api/v1/cookbooks/redis-test",
          },
          "collaborates" => {
            "zeromq" => "http://www.example.com/api/v1/cookbooks/zeromq",
          },
          "follows" => {
            "ruby" => "http://www.example.com/api/v1/cookbooks/ruby",
            "postgres" => "http://www.example.com/api/v1/cookbooks/postgres",
          },
        },
        "tools" => {
          "owns" => {
            "berkshelf" => "http://www.example.com/api/v1/tools/berkshelf",
            "knife_supermarket" => "http://www.example.com/api/v1/tools/knife_supermarket",
          },
          "collaborates" => {
            "dull_knife" => "http://www.example.com/api/v1/tools/dull_knife",
          },
        },
      }
    end

    before do
      create(
        :account,
        provider: "github",
        username: "fanny",
        user: user
      )
      create(:cookbook, name: "redis-test", owner: user)
      create(:cookbook, name: "macand", owner: user)
      create(
        :cookbook_collaborator,
        resourceable: create(:cookbook, name: "zeromq"),
        user: user
      )
      create(
        :cookbook_follower,
        cookbook: create(:cookbook, name: "postgres"),
        user: user
      )
      create(
        :cookbook_follower,
        cookbook: create(:cookbook, name: "ruby"),
        user: user
      )

      create(:tool, name: "berkshelf", owner: user, slug: "berkshelf")
      create(
        :tool, name: "knife_supermarket", owner: user, slug: "knife_supermarket"
      )

      create(
        :tool_collaborator,
        resourceable: create(:tool, name: "dull_knife", slug: "dull_knife"),
        user: user
      )
    end

    it "returns a 200" do
      get "/api/v1/users/fanny"

      expect(response.status.to_i).to eql(200)
    end

    it "returns the user" do
      get "/api/v1/users/fanny"

      expect(signature(json_body)).to include(user_signature)
    end
  end

  context "when the user does not exist" do
    it "returns a 404" do
      get "/api/v1/users/notauser"

      expect(response.status.to_i).to eql(404)
    end

    it "returns a 404 message" do
      get "/api/v1/users/notauser"

      expect(json_body).to eql(error_404)
    end
  end
end
