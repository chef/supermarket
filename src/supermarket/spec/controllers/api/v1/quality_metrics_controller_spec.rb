require "spec_helper"

describe Api::V1::QualityMetricsController do
  describe "#create_metric (private)" do
    let(:version) { create :cookbook_version }
    let(:metric) { create :foodcritic_metric }

    it "creates a metric result for a cookbook version" do
      new_result = subject.send(:create_metric, version, metric, false, "Looks OK.")

      expect(version.metric_results.last).to eq(new_result)
    end

    it "removes previous metric results in favor of the latest created" do
      3.times { create :metric_result, cookbook_version: version, quality_metric: metric }

      latest_result = subject.send(:create_metric, version, metric, false, "Looks OK.")

      expect(version.metric_results.count).to eq(1)
      expect(version.metric_results.last).to eq(latest_result)
    end

    it "leaves previous metric results of different types intact" do
      other_metric = create :collaborator_num_metric
      create :metric_result, cookbook_version: version, quality_metric: other_metric

      subject.send(:create_metric, version, metric, false, "Looks OK.")

      expect(version.metric_results.count).to eq(2)
    end
  end

  describe "#foodcritic_evaluation" do
    let(:cookbook) { create(:cookbook) }
    let!(:version) { create(:cookbook_version, cookbook: cookbook) }
    let!(:version_2) { create(:cookbook_version, cookbook: cookbook) }

    context "the request is authorized" do
      context "the cookbook version exists" do
        it "finds the correct cookbook version" do
          post(:foodcritic_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version_2.to_param, foodcritic_failure: true, foodcritic_feedback: "E066", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(assigns[:cookbook_version]).to eq(version_2)
        end

        context "the required params are provided" do
          it "returns a 200" do
            post(:foodcritic_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.to_param, foodcritic_failure: true, foodcritic_feedback: "E066", fieri_key: "YOUR_FIERI_KEY", format: :json })

            expect(response.status.to_i).to eql(200)
          end

          it "adds a metric result for foodcritic" do
            quality_metric = create(:foodcritic_metric)

            post(:foodcritic_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.to_param, foodcritic_failure: true, foodcritic_feedback: "E066", fieri_key: "YOUR_FIERI_KEY", format: :json })

            expect(version.metric_results.where(quality_metric: quality_metric).count).to eq(1)
          end

          # License metric has been deprecated in favor of the equivalent Foodcritic rule.
          # Remove old License metric results now that a Foodcritic result has been made that
          # checks for licensing.
          it "removes an existing license metric" do
            create(:foodcritic_metric)
            license_metric = create(:license_metric)
            create :metric_result, cookbook_version: version, quality_metric: license_metric

            expect(version.metric_results.where(quality_metric: license_metric).count).to eq(1)

            post(:foodcritic_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.to_param, foodcritic_failure: true, foodcritic_feedback: "E066", fieri_key: "YOUR_FIERI_KEY", format: :json })

            expect(version.metric_results.where(quality_metric: license_metric).count).to eq(0)
          end

          context "the required params are not provided" do
            it "returns a 400" do
              post(:foodcritic_evaluation, params: { cookbook_name: cookbook.name, foodcritic_failure: "false", foodcritic_feedback: "", fieri_key: "YOUR_FIERI_KEY", format: :json })

              expect(response.status.to_i).to eql(400)

              expect(JSON.parse(response.body)).to eql(
                "error_code" => I18n.t("api.error_codes.invalid_data"),
                "error_messages" => [
                  I18n.t("api.error_messages.missing_cookbook_version"),
                ]
              )
            end
          end
        end
      end

      context "the cookbook version does not exist" do
        it "returns a 404" do
          post(:foodcritic_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: "1010101.1.1", foodcritic_failure: true, foodcritic_feedback: "E066", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(response.status.to_i).to eql(404)
        end
      end
    end

    context "the request is not authorized" do
      it "renders a 401 error about unauthorized post" do
        post(:foodcritic_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: "1010101.1.1", foodcritic_failure: true, foodcritic_feedback: "E066", fieri_key: "not_the_key", format: :json })

        expect(response.status.to_i).to eql(401)
        expect(JSON.parse(response.body)).to eql(
          "error_code" => I18n.t("api.error_codes.unauthorized"),
          "error_messages" => [
            I18n.t("api.error_messages.unauthorized_post_error"),
          ]
        )
      end
    end
  end

  describe "#no_binaries_evaluation" do
    let(:cookbook) { create(:cookbook) }
    let!(:version) { create(:cookbook_version, cookbook: cookbook) }
    let!(:version_2) { create(:cookbook_version, cookbook: cookbook) }

    context "the request is authorized" do
      context "the cookbook version exists" do
        it "finds the correct cookbook version" do
          post(:no_binaries_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version_2.to_param, no_binaries_failure: true, no_binaries_evaluation: "Binaries inside. :(", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(assigns[:cookbook_version]).to eq(version_2)
        end

        context "the required params are provided" do
          it "returns a 200" do
            post(:no_binaries_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.to_param, no_binaries_failure: true, no_binaries_feedback: "Binaries inside. :(", fieri_key: "YOUR_FIERI_KEY", format: :json })

            expect(response.status.to_i).to eql(200)
          end

          it "adds a metric result for no binaries check" do
            quality_metric = create(:no_binaries_metric)

            post(:no_binaries_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.to_param, no_binaries_failure: true, no_binaries_feedback: "Binaries inside. :(", fieri_key: "YOUR_FIERI_KEY", format: :json })

            expect(version.metric_results.where(quality_metric: quality_metric).count).to eq(1)
          end

          context "the required params are not provided" do
            it "returns a 400" do
              post(:no_binaries_evaluation, params: { cookbook_name: cookbook.name, no_binaries_failure: "false", no_binaries_feedback: "", fieri_key: "YOUR_FIERI_KEY", format: :json })

              expect(response.status.to_i).to eql(400)

              expect(JSON.parse(response.body)).to eql(
                "error_code" => I18n.t("api.error_codes.invalid_data"),
                "error_messages" => [
                  I18n.t("api.error_messages.missing_cookbook_version"),
                ]
              )
            end
          end
        end
      end

      context "the cookbook version does not exist" do
        it "returns a 404" do
          post(:no_binaries_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: "1010101.1.1", no_binaries_failure: true, no_binaries_feedback: "Binaries inside. :(", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(response.status.to_i).to eql(404)
        end
      end
    end

    context "the request is not authorized" do
      it "renders a 401 error about unauthorized post" do
        post(:no_binaries_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: "1010101.1.1", no_binaries_failure: true, no_binaries_feedback: "Binaries inside. :(", fieri_key: "not_the_key", format: :json })

        expect(response.status.to_i).to eql(401)
        expect(JSON.parse(response.body)).to eql(
          "error_code" => I18n.t("api.error_codes.unauthorized"),
          "error_messages" => [
            I18n.t("api.error_messages.unauthorized_post_error"),
          ]
        )
      end
    end
  end

  describe "#collaborators_evaluation" do
    let(:cookbook) { create(:cookbook) }
    let!(:version) { create(:cookbook_version, cookbook: cookbook) }
    let!(:version_2) { create(:cookbook_version, cookbook: cookbook) }

    context "the request is authorized" do
      context "the required params are provided" do
        it "finds the latest cookbook version" do
          post(:collaborators_evaluation, params: { cookbook_name: cookbook.name, collaborator_failure: false, collaborator_feedback: "This cookbook does not have sufficient collaborators.", fieri_key: "YOUR_FIERI_KEY", format: :json })
          expect(assigns[:cookbook_version]).to eq(version_2)
        end

        it "returns a 200" do
          post(:collaborators_evaluation, params: { cookbook_name: cookbook.name, collaborator_failure: false, collaborator_feedback: "This cookbook does not have sufficient collaborators.", fieri_key: "YOUR_FIERI_KEY", format: :json })
          expect(response.status.to_i).to eql(200)
        end

        it "updates the cookbook version's collaborator attributes" do
          quality_metric = create(:collaborator_num_metric)

          post(:collaborators_evaluation, params: { cookbook_name: cookbook.name, collaborator_failure: false, collaborator_feedback: "This cookbook does not have sufficient collaborators.", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(version_2.metric_results.where(quality_metric: quality_metric).count).to eq(1)
        end
      end

      context "the required params are not provided" do
        it "returns a 400" do
          post(:collaborators_evaluation, params: { collaborator_failure: false, collaborator_feedback: "", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(response.status.to_i).to eql(400)

          expect(JSON.parse(response.body)).to eql(
            "error_code" => I18n.t("api.error_codes.invalid_data"),
            "error_messages" => [
              I18n.t("api.error_messages.missing_cookbook_name"),
            ]
          )
        end
      end
    end

    context "the request is not authorized" do
      it "renders a 401 error about unauthorized post" do
        post(:collaborators_evaluation, params: { cookbook_name: cookbook.name, collaborator_failure: true, collaborator_feedback: "E066", fieri_key: "not_the_key", format: :json })

        expect(response.status.to_i).to eql(401)
        expect(JSON.parse(response.body)).to eql(
          "error_code" => I18n.t("api.error_codes.unauthorized"),
          "error_messages" => [
            I18n.t("api.error_messages.unauthorized_post_error"),
          ]
        )
      end
    end
  end

  describe "#license_evaluation (deprecated)" do
    it "returns a 410 Gone" do
      post(:license_evaluation, params: { literally: "anything" })
      expect(response.status.to_i).to eql(410)
    end

    it "includes a friendly message in the response" do
      post(:license_evaluation, params: { literally: "anything" })
      expect(response.body).to match(/deprecated/)
    end
  end

  describe "#supported_platforms_evaluation" do
    let(:cookbook) { create(:cookbook) }
    let!(:version) { create(:cookbook_version, cookbook: cookbook) }
    let!(:quality_metric) { create(:supported_platforms_metric) }

    context "the request is authorized" do
      context "the required params are provided" do
        it "returns a 200" do
          post(:supported_platforms_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, supported_platforms_failure: false, supported_platforms_feedback: "This cookbook does not exist.", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(response.status.to_i).to eql(200)
        end

        it "creates a supported platforms metric" do
          post(:supported_platforms_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, supported_platforms_failure: false, supported_platforms_feedback: "This cookbook does not exist.", fieri_key: "YOUR_FIERI_KEY", format: :json })

          version.reload
          expect(version.metric_results.where(quality_metric: quality_metric).count).to eq(1)
        end

        it "finds the correct cookbook version" do
          post(:supported_platforms_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, supported_platforms_failure: false, supported_platforms_feedback: "This cookbook does not exist.", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(assigns[:cookbook_version]).to eq(version)
        end
      end

      context "the required params are not provided" do
        it "returns a 400" do
          post(:supported_platforms_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(response.status.to_i).to eql(400)
        end
      end
    end

    context "the request is not authorized" do
      it "renders a 401 error about unauthorized post" do
        post(:supported_platforms_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, supported_platforms_failure: false, supported_platforms_feedback: "This cookbook does not exist.", fieri_key: "not_the_key", format: :json })

        expect(response.status.to_i).to eql(401)
        expect(JSON.parse(response.body)).to eql(
          "error_code" => I18n.t("api.error_codes.unauthorized"),
          "error_messages" => [
            I18n.t("api.error_messages.unauthorized_post_error"),
          ]
        )
      end
    end
  end

  describe "#contributing_file_evaluation" do
    let(:cookbook) { create(:cookbook) }
    let!(:version) { create(:cookbook_version, cookbook: cookbook) }
    let!(:quality_metric) { create(:contributing_file_metric) }

    context "the request is authorized" do
      context "the required params are provided" do
        it "returns a 200" do
          post(:contributing_file_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, contributing_file_failure: false, contributing_file_feedback: "passed", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(response.status.to_i).to eql(200)
        end

        it "creates a contributing file metric" do
          post(:contributing_file_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, contributing_file_failure: false, contributing_file_feedback: "passed", fieri_key: "YOUR_FIERI_KEY", format: :json })

          version.reload
          expect(version.metric_results.where(quality_metric: quality_metric).count).to eq(1)
          expect(version.metric_results.first.failure).to eq(false)
        end

        it "finds the correct cookbook version" do
          post(:contributing_file_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, contributing_file_failure: false, contributing_file_feedback: "passed", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(assigns[:cookbook_version]).to eq(version)
        end
      end

      context "the required params are not provided" do
        it "returns a 400" do
          post(:contributing_file_evaluation, params: { cookbook_name: cookbook.name, contributing_file_failure: false, fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(response.status.to_i).to eql(400)
        end
      end
    end

    context "the request is not authorized" do
      it "renders a 401 error about unauthorized post" do
        post(:contributing_file_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, contributing_file_failure: false, fieri_key: "not_the_key", format: :json })

        expect(response.status.to_i).to eql(401)
      end
    end
  end

  describe "#testing_file_evaluation" do
    let(:cookbook) { create(:cookbook) }
    let!(:version) { create(:cookbook_version, cookbook: cookbook) }
    let!(:quality_metric) { create(:testing_file_metric) }

    context "the request is authorized" do
      context "the required params are provided" do
        it "returns a 200" do
          post(:testing_file_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, testing_file_failure: false, testing_file_feedback: "passed", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(response.status.to_i).to eql(200)
        end

        it "creates a testing file metric" do
          post(:testing_file_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, testing_file_failure: false, testing_file_feedback: "passed", fieri_key: "YOUR_FIERI_KEY", format: :json })

          version.reload
          expect(version.metric_results.where(quality_metric: quality_metric).count).to eq(1)
          expect(version.metric_results.first.failure).to eq(false)
        end

        it "finds the correct cookbook version" do
          post(:testing_file_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, testing_file_failure: false, testing_file_feedback: "passed", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(assigns[:cookbook_version]).to eq(version)
        end
      end

      context "the required params are not provided" do
        it "returns a 400" do
          post(:testing_file_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, testing_file_failure: false, fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(response.status.to_i).to eql(400)
        end
      end

      context "the request is not authorized" do
        it "renders a 401 error about unauthorized post" do
          post(:testing_file_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, testing_file_failure: false, testing_file_feedback: "passed", fieri_key: "not_the_key", format: :json })

          expect(response.status.to_i).to eql(401)
        end
      end
    end
  end

  describe "#version_tag_evaluation" do
    let(:cookbook) { create(:cookbook) }
    let!(:version) { create(:cookbook_version, cookbook: cookbook) }
    let!(:quality_metric) { create(:version_tag_metric) }

    context "the request is authorized" do
      context "the required params are provided" do
        it "returns a 200" do
          post(:version_tag_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, version_tag_failure: false, version_tag_feedback: "passed", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(response.status.to_i).to eql(200)
        end

        it "creates a testing file metric" do
          post(:version_tag_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, version_tag_failure: false, version_tag_feedback: "passed", fieri_key: "YOUR_FIERI_KEY", format: :json })

          version.reload
          expect(version.metric_results.where(quality_metric: quality_metric).count).to eq(1)
          expect(version.metric_results.first.failure).to eq(false)
        end

        it "finds the correct cookbook version" do
          post(:version_tag_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, version_tag_failure: false, version_tag_feedback: "passed", fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(assigns[:cookbook_version]).to eq(version)
        end
      end

      context "the required params are not provided" do
        it "returns a 400" do
          post(:version_tag_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, version_tag_failure: false, fieri_key: "YOUR_FIERI_KEY", format: :json })

          expect(response.status.to_i).to eql(400)
        end
      end

      context "the request is not authorized" do
        it "renders a 401 error about unauthorized post" do
          post(:version_tag_evaluation, params: { cookbook_name: cookbook.name, cookbook_version: version.version, version_tag_failure: false, version_tag_feedback: "passed", fieri_key: "not_the_key", format: :json })

          expect(response.status.to_i).to eql(401)
        end
      end
    end
  end
end
