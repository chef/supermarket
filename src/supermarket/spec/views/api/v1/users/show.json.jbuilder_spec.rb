require "spec_helper"

describe "api/v1/users/show" do
  let!(:user) do
    create(
      :user,
      first_name: "Fanny",
      last_name: "McNanny",
      company: "FannyInternational",
      twitter_username: "fannyfannyfanny",
      email: "fanny@fanny.com",
      slack_username: "fannyfunnyfanny"
    )
  end

  before do
    create(
      :account,
      provider: "chef_oauth2",
      username: "fanny",
      user: user
    )
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

    assign(:user, user)
    assign(:owned_cookbooks, user.owned_cookbooks)
    assign(:collaborated_cookbooks, user.collaborated_cookbooks)
    assign(:followed_cookbooks, user.followed_cookbooks)
    assign(:github_usernames, user.accounts.for("github").map(&:username))
    assign(:owned_tools, user.tools)
    assign(:collaborated_tools, user.collaborated_tools)

    render
  end

  it "displays the user's chef username" do
    username = json_body["username"]
    expect(username).to eql(user.username)
  end

  it "displays the user's name" do
    name = json_body["name"]
    expect(name).to eql(user.name)
  end

  it "displays the user's company" do
    company = json_body["company"]
    expect(company).to eql(user.company)
  end

  it "displays the user's github accounts" do
    github = json_body["github"]
    expect(github).to eql(["fanny"])
  end

  it "displays the user's twitter handle" do
    twitter = json_body["twitter"]
    expect(twitter).to eql(user.twitter_username)
  end

  it "displays the user's irc handle" do
    slack = json_body["slack"]
    expect(slack).to eql(user.slack_username)
  end

  it "displays the cookbooks the user owns" do
    owned_cookbooks = json_body["cookbooks"]["owns"]
    expect(owned_cookbooks).to eql(
      "macand" => "http://test.host/api/v1/cookbooks/macand",
      "redis-test" => "http://test.host/api/v1/cookbooks/redis-test"
    )
  end

  it "displays the cookbooks the user collaborates on" do
    collaborates_cookbooks = json_body["cookbooks"]["collaborates"]
    expect(collaborates_cookbooks).to eql(
      "zeromq" => "http://test.host/api/v1/cookbooks/zeromq"
    )
  end

  it "displays the cookbooks the user follows" do
    follows_cookbooks = json_body["cookbooks"]["follows"]
    expect(follows_cookbooks).to eql(
      "postgres" => "http://test.host/api/v1/cookbooks/postgres",
      "ruby" => "http://test.host/api/v1/cookbooks/ruby"
    )
  end

  it "displays the tools the user owns" do
    owned_tools = json_body["tools"]["owns"]
    expect(owned_tools).to eql(
      "berkshelf" => "http://test.host/api/v1/tools/berkshelf",
      "knife_supermarket" => "http://test.host/api/v1/tools/knife_supermarket"
    )
  end

  it "displays the tools the user collaborates on" do
    collaborates_tools = json_body["tools"]["collaborates"]
    expect(collaborates_tools).to eql(
      "dull_knife" => "http://test.host/api/v1/tools/dull_knife"
    )
  end
end
