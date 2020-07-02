require "spec_helper"

describe "api/v1/metrics/show" do
  before do
    assign(:metrics,
           total_cookbook_downloads: 5,
           total_cookbook_versions: 4,
           total_cookbooks: 3,
           total_follows: 2,
           total_users: 6,
           total_hits: {
             "/universe" => 3,
           })
  end

  it "displays the metrics" do
    render

    expect(json_body["total_cookbook_downloads"]).to eql(5)
    expect(json_body["total_cookbook_versions"]).to eql(4)
    expect(json_body["total_cookbooks"]).to eql(3)
    expect(json_body["total_follows"]).to eql(2)
    expect(json_body["total_users"]).to eql(6)
    expect(json_body["total_hits"]).to include("/universe" => 3)
  end
end
