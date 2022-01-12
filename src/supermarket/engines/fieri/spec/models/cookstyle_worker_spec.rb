require "rails_helper"

describe CookstyleWorker do
  let(:valid_params) do
    { "artifact_url" => "http://example.com/apache.tar.gz",
      "name" => "apache2",
      "version" => "1.2.0" }
  end

  let(:test_evaluation_endpoint) do
    "#{ENV["FIERI_SUPERMARKET_ENDPOINT"]}/api/v1/quality_metrics/cookstyle_evaluation"
  end

  before do
    #
    # Stubs criticize for speed!
    #
    allow_any_instance_of(CookbookArtifact).to receive(:criticize)
      .and_return("Chef/Deprecations/ResourceWithoutUnifiedTrue", true)

    #
    # Stubs cleanup so we can test the creation of unique
    # directories.
    #
    allow_any_instance_of(CookbookArtifact).to receive(:cleanup)
      .and_return(0)

    stub_request(:get, "http://example.com/apache.tar.gz")
      .to_return(
        body: File.open(File.expand_path("./spec/fixtures/apache.tar.gz")),
        status: 200
      )

    stub_request(:post, test_evaluation_endpoint)
      .with(body: hash_including(cookbook_name: "apache2"))
  end

  it "sends a post request to the results endpoint" do
    subject.perform(valid_params)

    assert_requested(:post, test_evaluation_endpoint) do |req|
      req.body =~ /cookstyle_failure=true/
      req.body =~ /Chef\/Deprecations\/ResourceWithoutUnifiedTrue:/
      req.body =~ /#{Cookstyle::VERSION}/
      ENV["COOKSTYLE_COPS"].split(/\s|,/).each do |tag|
        expect(req.body).to include(tag.gsub("/","%2F"))
      end

    end
  end

  describe "when posting results back to Supermarket" do
    let(:not_gonna_work_params) do
      valid_params.merge("name" => "not_gonna_work")
    end

    it "rescues a POST error" do
      stub_request(:post, test_evaluation_endpoint)
        .with(body: hash_including(cookbook_name: "not_gonna_work"))
        .to_return(status: 502, body: "", headers: {})

      expect(subject).to receive(:log_error)

      subject.perform(not_gonna_work_params)
    end

    it "rescues a timeout" do
      stub_request(:post, test_evaluation_endpoint)
        .with(body: hash_including(cookbook_name: "not_gonna_work"))
        .to_timeout

      expect(subject).to receive(:log_error)

      subject.perform(not_gonna_work_params)
    end
  end
end
