require "rails_helper"

describe VersionTagWorker do
  let(:vfw) { VersionTagWorker.new }
  let(:cookbook_name) { "apache" }
  let(:cookbook_version) { "2.9.16" }

  before do
    stub_request(:post, "#{ENV["FIERI_SUPERMARKET_ENDPOINT"]}/api/v1/quality_metrics/version_tag_evaluation")
      .to_return(status: 200, body: "", headers: {})
  end

  context "when a version tag is present" do
    let(:cookbook_json_response) { File.read("spec/support/cookbook_source_url_fixture.json") }
    let(:github_tag_present_response) { File.read("spec/support/github_version_tag_positive.json") }
    let(:octokit) { Octokit::Client.new(access_token: ENV["FIERI_SUPERMARKET_ENDPOINT"]) }

    before do
      allow(Octokit::Client).to receive(:new).and_return(octokit)

      stub_request(:get, "https://api.github.com/repos/johndoe/example_repo/tags")
        .to_return(status: 200, body: JSON.parse(github_tag_present_response), headers: {})
    end

    it "calls the Octokit API wrapper" do
      expect(Octokit::Client).to receive(:new).with(access_token: ENV["GITHUB_ACCESS_TOKEN"]).and_return(octokit)
      vfw.perform(cookbook_json_response, cookbook_name, cookbook_version)
    end

    context "parsing the source url" do
      let(:parsed_response) { JSON.parse(cookbook_json_response) }
      let(:github_repo_url_regex) { %r{^(https?\://)?(github\.com/)(\w+/\w+)} }

      it "parses the cookbook_json" do
        expect(JSON).to receive(:parse).with(cookbook_json_response).and_return(parsed_response)
        vfw.perform(cookbook_json_response, cookbook_name, cookbook_version)
      end

      it "attempts to find a match for a github url" do
        sample_source_url = "https://github.com/johndoe/example_repo"
        allow_any_instance_of(SourceRepoWorker).to receive(:source_repo_url).and_return(sample_source_url)
        expect(github_repo_url_regex).to match(sample_source_url)
        expect(sample_source_url.match(github_repo_url_regex)[3]).to eq("johndoe/example_repo")
        vfw.perform(cookbook_json_response, cookbook_name, cookbook_version)
      end
    end

    context "when a source url is valid" do
      # to be valid, must be a github url
      let(:octokit_response) { octokit.tags("johndoe/example_repo") }
      let(:expected_tags) { octokit_response.map { |tag| tag["name"] } }

      before do
        allow(octokit).to receive(:tags).and_return(octokit_response)
      end

      it "pulls the tag list of the repo" do
        expect(octokit).to receive(:tags).with("johndoe/example_repo").and_return(expected_tags)
        vfw.perform(cookbook_json_response, cookbook_name, cookbook_version)
      end

      it "maps the version tag names" do
        octokit_response = octokit.tags("johndoe/example_repo")

        expect(octokit_response).to receive(:map).and_return(expected_tags)
        vfw.perform(cookbook_json_response, cookbook_name, cookbook_version)
      end

      it "looks for a version tag which matches the cookbook version" do
        allow(octokit_response).to receive(:map).and_return(expected_tags)
        expect(expected_tags).to receive(:include?).with(cookbook_version).and_return(true)
        vfw.perform(cookbook_json_response, cookbook_name, cookbook_version)
      end

      context "and an appropriate tag is present" do
        it "posts a passing metric" do
          vfw.perform(cookbook_json_response, cookbook_name, cookbook_version)

          assert_requested(:post, "#{ENV["FIERI_SUPERMARKET_ENDPOINT"]}/api/v1/quality_metrics/version_tag_evaluation", times: 1) do |req|
            expect(req.body).to include("cookbook_name=#{cookbook_name}")
            expect(req.body).to include("cookbook_version=#{cookbook_version}")
            expect(req.body).to include("version_tag_failure=false")
            expect(req.body).to include("version_tag_feedback=passed")
          end
        end
      end

      context "but the repo declared in metadata does not exist" do
        before do
          allow(octokit).to receive(:tags).and_raise(Octokit::NotFound)
        end

        it "posts a failing metric" do
          vfw.perform(cookbook_json_response, cookbook_name, cookbook_version)

          assert_requested(:post, "#{ENV["FIERI_SUPERMARKET_ENDPOINT"]}/api/v1/quality_metrics/version_tag_evaluation", times: 1) do |req|
            expect(req.body).to include("cookbook_name=#{cookbook_name}")
            expect(req.body).to include("version_tag_failure=true")
            expect(req.body).to include("version_tag_feedback=Failure")
          end
        end
      end

      context "when the tag has a v in the version number" do
        let(:github_tag_present_response) { File.read("spec/support/github_version_tag_with_v_in_number.json") }
        let(:cookbook_version) { "2.9.14" }

        before do
          allow(Octokit::Client).to receive(:new).and_return(octokit)

          stub_request(:get, "https://api.github.com/repos/johndoe/example_repo/tags")
            .to_return(status: 200, body: JSON.parse(github_tag_present_response), headers: {})
        end

        it "posts a passing metric" do
          octokit_response = octokit.tags("johndoe/example_repo")
          expected_tags = octokit_response.map { |tag| tag["name"] }
          expect(expected_tags).to include("v#{cookbook_version}")

          allow(octokit_response).to receive(:map).and_return(expected_tags)

          vfw.perform(cookbook_json_response, cookbook_name, cookbook_version)
          assert_requested(:post, "#{ENV["FIERI_SUPERMARKET_ENDPOINT"]}/api/v1/quality_metrics/version_tag_evaluation", times: 1) do |req|
            expect(req.body).to include("cookbook_name=#{cookbook_name}")
            expect(req.body).to include("cookbook_version=#{cookbook_version}")
            expect(req.body).to include("version_tag_failure=false")
            expect(req.body).to include("version_tag_feedback=passed")
          end
        end
      end

      context "and an appropriate tag is not present" do
        let(:non_present_tag) { "5.0.0" }
        let(:cookbook_version) { non_present_tag }

        before do
          expect(expected_tags).to_not include(non_present_tag)
        end

        it "posts a failing metric" do
          vfw.perform(cookbook_json_response, cookbook_name, cookbook_version)

          assert_requested(:post, "#{ENV["FIERI_SUPERMARKET_ENDPOINT"]}/api/v1/quality_metrics/version_tag_evaluation", times: 1) do |req|
            expect(req.body).to include("cookbook_name=#{cookbook_name}")
            expect(req.body).to include("cookbook_version=#{cookbook_version}")
            expect(req.body).to include("version_tag_failure=true")
            expect(req.body).to include("version_tag_feedback=Failure")
          end
        end
      end
    end

    context "when a source url is not valid" do
      let(:invalid_source_url_json_response) { File.read("spec/support/cookbook_null_source_url_fixture.json") }

      it "does not attempt to contact the Github API" do
        expect(Octokit::Client).to_not receive(:new)
        vfw.perform(invalid_source_url_json_response, cookbook_name, cookbook_version)
      end

      it "posts a failing metric" do
        vfw.perform(invalid_source_url_json_response, cookbook_name, cookbook_version)

        assert_requested(:post, "#{ENV["FIERI_SUPERMARKET_ENDPOINT"]}/api/v1/quality_metrics/version_tag_evaluation", times: 1) do |req|
          expect(req.body).to include("cookbook_name=#{cookbook_name}")
          expect(req.body).to include("version_tag_failure=true")
          expect(req.body).to include("version_tag_feedback=Failure")
        end
      end
    end
  end
end
