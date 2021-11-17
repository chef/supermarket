require "spec_helper"

describe "GET /api/v1/cookbooks/:cookbook/versions/:version" do
  context "for a cookbook that exists" do
    before do
      user = create(:user)

      share_cookbook("redis-test", user, custom_metadata: { version: "0.1.0" })
      share_cookbook("redis-test", user, custom_metadata: { version: "0.2.0" })

      get json_body["uri"]
    end

    context "for the latest version" do
      let(:cookbook_version_signature) do
        {
          "license" => "MIT",
          "version" => "0.2.0",
          "average_rating" => nil,
          "cookbook" => "http://www.example.com/api/v1/cookbooks/redis-test",
        }
      end

      it "returns a 200" do
        get "/api/v1/cookbooks/redis-test/versions/latest"

        expect(response.status.to_i).to eql(200)
      end

      it "returns a version of the cookbook" do
        get "/api/v1/cookbooks/redis-test/versions/latest"

        expect(signature(json_body)).to include(cookbook_version_signature)
      end
    end

    context "for a version that exists" do
      let(:cookbook) { Cookbook.where(name: "redis-test").first }

      let(:cookbook_version_signature) do
        {
          "license" => "MIT",
          "version" => "0.1.0",
          "average_rating" => nil,
          "cookbook" => "http://www.example.com/api/v1/cookbooks/redis-test",
        }
      end

      let(:cookbook_version) { cookbook.cookbook_versions.where(version: "0.1.0").first }

      let(:quality_metric_cookstyle) do
        create(:cookstyle_metric)
      end

      let(:quality_metric_collab_num) do
        create(:collaborator_num_metric)
      end

      let!(:cookstyle_result) do
        create(:metric_result,
               cookbook_version: cookbook_version,
               quality_metric: quality_metric_cookstyle)
      end

      let!(:collab_result) do
        create(:metric_result,
               cookbook_version: cookbook_version,
               quality_metric: quality_metric_collab_num)
      end

      let(:quality_metrics) do
        {
          "quality_metrics" => [
            {
              "name" => quality_metric_cookstyle.name,
              "failed" => cookstyle_result.failure,
              "feedback" => cookstyle_result.feedback,
            },
            {
              "name" => quality_metric_collab_num.name,
              "failed" => collab_result.failure,
              "feedback" => collab_result.feedback,
            },
          ],
        }
      end

      before do
        cookbook.reload
      end

      it "returns a 200" do
        get(json_body["versions"].find { |v| v =~ /0.1.0/ })

        expect(response.status.to_i).to eql(200)
      end

      it "returns a version of the cookbook" do
        get(json_body["versions"].find { |v| v =~ /0.1.0/ })

        expect(signature(json_body)).to include(cookbook_version_signature)
      end

      it "returns the date the version was published" do
        get(json_body["versions"].find { |v| v =~ /0.1.0/ })

        expect(signature(json_body)).to include("published_at" => cookbook_version.created_at.iso8601)
      end

      it "includes a list of supported platforms" do
        get(json_body["versions"].find { |v| v =~ /0.1.0/ })

        supported_platforms_signature = { "supports" => { "ubuntu" => ">= 12.0.0" } }

        expect(signature(json_body)).to include(supported_platforms_signature)
      end

      context "when the fieri feature is active" do
        before do
          allow(Feature).to receive(:active?).with(:fieri).and_return(true)
        end

        it "returns quality metrics for the cookbook version" do
          get "/api/v1/cookbooks/#{cookbook.name}/versions/#{cookbook_version.version}"
          expect(JSON.parse(response.body)).to include(quality_metrics)
        end

        context "when the cookbook has only the cookstyle metric" do
          before do
            collab_result.destroy
          end

          it "returns a 200" do
            get "/api/v1/cookbooks/#{cookbook.name}/versions/#{cookbook_version.version}"

            expect(response.status.to_i).to eql(200)
          end
        end
      end

      context "when the fieri feature is not active" do
        before do
          allow(Feature).to receive(:active?).with(:fieri).and_return(false)
        end

        it "does not return quality metrics for the cookbook version" do
          get "/api/v1/cookbooks/#{cookbook.name}/versions/#{cookbook_version.version}"
          expect(JSON.parse(response.body)).to_not include(quality_metrics)
        end
      end
    end

    context "for a version that does not exist" do
      it "returns a 404" do
        get "/api/v1/cookbooks/sashimi/versions/2_1_0"

        expect(response.status.to_i).to eql(404)
      end

      it "returns a 404 message" do
        get "/api/v1/cookbooks/sashimi/versions/2_1_0"

        expect(json_body).to eql(error_404)
      end
    end
  end

  context "for a cookbook that does not exist" do
    it "returns a 404" do
      get "/api/v1/cookbooks/mamimi/versions/1_3_0"

      expect(response.status.to_i).to eql(404)
    end

    it "returns a 404 message" do
      get "/api/v1/cookbooks/mamimi/versions/1_333"

      expect(json_body).to eql(error_404)
    end
  end
end
