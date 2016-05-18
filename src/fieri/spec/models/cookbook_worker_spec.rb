require 'rails_helper'

describe CookbookWorker do
  before do
    #
    # Stubs criticize for speed!
    #
    CookbookArtifact.any_instance.stub(:criticize)
      .and_return("FC023", true)

    #
    # Stubs cleanup so we can test the creation of unique
    # directories.
    #
    CookbookArtifact.any_instance.stub(:cleanup)
      .and_return(0)

    stub_request(:get, "http://example.com/apache.tar.gz").
      to_return(
        :body => File.open(File.expand_path("./spec/fixtures/apache.tar.gz")),
        :status => 200
      )

    stub_request(:post, ENV["RESULTS_ENDPOINT"])
  end

  it "sends a post request to the results endpoint" do
    CookbookWorker.new.perform(
      "cookbook_artifact_url" => "http://example.com/apache.tar.gz",
      "cookbook_name" => "apache2",
      "cookbook_version" => "1.2.0"
    )

    assert_requested(:post, ENV["RESULTS_ENDPOINT"], :times => 1) do |req|
      req.body =~ /foodcritic_failure=true/
      req.body =~ /FC023/
    end
  end

  it "creates a unique directory for each job to work within" do
    Sidekiq::Testing.inline! do
      job_id_1 = CookbookWorker.perform_async(
        "cookbook_artifact_url" => "http://example.com/apache.tar.gz",
        "cookbook_name" => "apache2",
        "cookbook_version" => "1.2.0"
      )

      job_id_2 = CookbookWorker.perform_async(
        "cookbook_artifact_url" => "http://example.com/apache.tar.gz",
        "cookbook_name" => "apache2",
        "cookbook_version" => "1.2.0"
      )

      assert Dir.exist?(File.expand_path(Dir.tmpdir, job_id_1))
      assert Dir.exist?(File.expand_path(Dir.tmpdir, job_id_2))
    end
  end
end
