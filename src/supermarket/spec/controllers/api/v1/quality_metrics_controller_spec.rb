require 'spec_helper'

describe Api::V1::QualityMetricsController do
  describe '#foodcritic_evaluation' do
    let(:cookbook) { create(:cookbook) }
    let!(:version) { create(:cookbook_version, cookbook: cookbook) }
    let!(:version_2) { create(:cookbook_version, cookbook: cookbook) }

    context 'the request is authorized' do
      context 'the cookbook version exists' do
        it 'finds the correct cookbook version' do
          post(
            :foodcritic_evaluation,
            cookbook_name: cookbook.name,
            cookbook_version: version_2.to_param,
            foodcritic_failure: true,
            foodcritic_feedback: 'E066',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )

          expect(assigns[:cookbook_version]).to eq(version_2)
        end

        context 'the required params are provided' do
          it 'returns a 200' do
            post(
              :foodcritic_evaluation,
              cookbook_name: cookbook.name,
              cookbook_version: version.to_param,
              foodcritic_failure: true,
              foodcritic_feedback: 'E066',
              fieri_key: 'YOUR_FIERI_KEY',
              format: :json
            )

            expect(response.status.to_i).to eql(200)
          end

          it "adds a metric result for foodcritic" do
            quality_metric = create(:foodcritic_metric)

            post(
              :foodcritic_evaluation,
              cookbook_name: cookbook.name,
              cookbook_version: version.to_param,
              foodcritic_failure: true,
              foodcritic_feedback: 'E066',
              fieri_key: 'YOUR_FIERI_KEY',
              format: :json
            )

            expect(version.metric_results.where(quality_metric: quality_metric).count).to eq(1)
          end
        end

        context 'the required params are not provided' do
          it 'returns a 400' do
            post(
              :foodcritic_evaluation,
              cookbook_name: cookbook.name,
              foodcritic_failure: 'false',
              foodcritic_feedback: '',
              fieri_key: 'YOUR_FIERI_KEY',
              format: :json
            )

            expect(response.status.to_i).to eql(400)

            expect(JSON.parse(response.body)).to eql(
              'error_code' => I18n.t('api.error_codes.invalid_data'),
              'error_messages' => [
                I18n.t('api.error_messages.missing_cookbook_version')
              ]
            )
          end
        end
      end

      context 'the cookbook version does not exist' do
        it 'returns a 404' do
          post(
            :foodcritic_evaluation,
            cookbook_name: cookbook.name,
            cookbook_version: '1010101.1.1',
            foodcritic_failure: true,
            foodcritic_feedback: 'E066',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )

          expect(response.status.to_i).to eql(404)
        end
      end
    end

    context 'the request is not authorized' do
      it 'renders a 401 error about unauthorized post' do
        post(
          :foodcritic_evaluation,
          cookbook_name: cookbook.name,
          cookbook_version: '1010101.1.1',
          foodcritic_failure: true,
          foodcritic_feedback: 'E066',
          fieri_key: 'not_the_key',
          format: :json
        )

        expect(response.status.to_i).to eql(401)
        expect(JSON.parse(response.body)).to eql(
          'error_code' => I18n.t('api.error_codes.unauthorized'),
          'error_messages' => [
            I18n.t('api.error_messages.unauthorized_post_error')
          ]
        )
      end
    end
  end

  describe '#collaborators_evaluation' do
    let(:cookbook) { create(:cookbook) }
    let!(:version) { create(:cookbook_version, cookbook: cookbook) }
    let!(:version_2) { create(:cookbook_version, cookbook: cookbook) }

    context 'the request is authorized' do
      context 'the required params are provided' do
        it 'finds the latest cookbook version' do
          post(
            :collaborators_evaluation,
            cookbook_name: cookbook.name,
            collaborator_failure: false,
            collaborator_feedback: 'This cookbook does not have sufficient collaborators.',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )
          expect(assigns[:cookbook_version]).to eq(version_2)
        end

        it 'returns a 200' do
          post(
            :collaborators_evaluation,
            cookbook_name: cookbook.name,
            collaborator_failure: false,
            collaborator_feedback: 'This cookbook does not have sufficient collaborators.',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )
          expect(response.status.to_i).to eql(200)
        end

        it "updates the cookbook version's collaborator attributes" do
          quality_metric = create(:collaborator_num_metric)

          post(
            :collaborators_evaluation,
            cookbook_name: cookbook.name,
            collaborator_failure: false,
            collaborator_feedback: 'This cookbook does not have sufficient collaborators.',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )

          expect(version_2.metric_results.where(quality_metric: quality_metric).count).to eq(1)
        end
      end

      context 'the required params are not provided' do
        it 'returns a 400' do
          post(
            :collaborators_evaluation,
            collaborator_failure: false,
            collaborator_feedback: '',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )

          expect(response.status.to_i).to eql(400)

          expect(JSON.parse(response.body)).to eql(
            'error_code' => I18n.t('api.error_codes.invalid_data'),
            'error_messages' => [
              I18n.t('api.error_messages.missing_cookbook_name')
            ]
          )
        end
      end
    end

    context 'the request is not authorized' do
      it 'renders a 401 error about unauthorized post' do
        post(
          :collaborators_evaluation,
          cookbook_name: cookbook.name,
          collaborator_failure: true,
          collaborator_feedback: 'E066',
          fieri_key: 'not_the_key',
          format: :json
        )

        expect(response.status.to_i).to eql(401)
        expect(JSON.parse(response.body)).to eql(
          'error_code' => I18n.t('api.error_codes.unauthorized'),
          'error_messages' => [
            I18n.t('api.error_messages.unauthorized_post_error')
          ]
        )
      end
    end
  end

  describe '#publish_evaluation' do
    let(:cookbook) { create(:cookbook) }
    let!(:version) { create(:cookbook_version, cookbook: cookbook) }
    let!(:quality_metric) { create(:publish_metric) }

    context 'the request is authorized' do
      context 'the required params are provided' do
        it 'returns a 200' do
          post(
            :publish_evaluation,
            cookbook_name: cookbook.name,
            publish_failure: false,
            publish_feedback: 'This cookbook does not exist.',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )
          expect(response.status.to_i).to eql(200)
        end

        it "creates a publish metric" do
          post(
            :publish_evaluation,
            cookbook_name: cookbook.name,
            publish_failure: false,
            publish_feedback: 'This cookbook does not exist.',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )

          version.reload
          expect(version.metric_results.where(quality_metric: quality_metric).count).to eq(1)
        end

        it 'finds the correct cookbook version' do
          post(
            :publish_evaluation,
            cookbook_name: cookbook.name,
            publish_failure: false,
            publish_feedback: 'This cookbook does not exist.',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )

          expect(assigns[:cookbook_version]).to eq(version)
        end
      end

      context 'the required params are not provided' do
        it 'returns a 400' do
          post(
            :publish_evaluation,
            cookbook_name: cookbook.name,
            publish_failure: false,
            publish_feedback: '',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )

          expect(response.status.to_i).to eql(400)

          expect(JSON.parse(response.body)).to eql(
            'error_code' => I18n.t('api.error_codes.invalid_data'),
            'error_messages' => [
              I18n.t('api.error_messages.missing_publish_feedback')
            ]
          )
        end
      end
    end

    context 'the request is not authorized' do
      it 'renders a 401 error about unauthorized post' do
        post(
          :publish_evaluation,
          cookbook_name: cookbook.name,
          publish_failure: false,
          publish_feedback: '',
          fieri_key: 'not_the_key',
          format: :json
        )

        expect(response.status.to_i).to eql(401)
        expect(JSON.parse(response.body)).to eql(
          'error_code' => I18n.t('api.error_codes.unauthorized'),
          'error_messages' => [
            I18n.t('api.error_messages.unauthorized_post_error')
          ]
        )
      end
    end
  end

  describe '#license_evaluation' do
    let(:cookbook) { create(:cookbook) }
    let!(:version) { create(:cookbook_version, cookbook: cookbook) }
    let!(:quality_metric) { create(:license_metric) }

    context 'the request is authorized' do
      context 'the required params are provided' do
        it 'returns a 200' do
          post(
            :license_evaluation,
            cookbook_name: cookbook.name,
            cookbook_version: version.version,
            license_failure: false,
            license_feedback: 'This cookbook does not exist.',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )

          expect(response.status.to_i).to eql(200)
        end

        it 'creates a license metric' do
          post(
            :license_evaluation,
            cookbook_name: cookbook.name,
            cookbook_version: version.version,
            license_failure: false,
            license_feedback: 'This cookbook does not exist.',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )

          version.reload
          expect(version.metric_results.where(quality_metric: quality_metric).count).to eq(1)
        end

        it 'finds the correct cookbook version' do
          post(
            :license_evaluation,
            cookbook_name: cookbook.name,
            cookbook_version: version.version,
            license_failure: false,
            license_feedback: 'This cookbook does not exist.',
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )

          expect(assigns[:cookbook_version]).to eq(version)
        end
      end

      context 'the required params are not provided' do
        it 'returns a 400' do
          post(
            :license_evaluation,
            cookbook_name: cookbook.name,
            cookbook_version: version.version,
            fieri_key: 'YOUR_FIERI_KEY',
            format: :json
          )

          expect(response.status.to_i).to eql(400)
        end
      end
    end

    context 'the request is not authorized' do
      it 'renders a 401 error about unauthorized post' do
        post(
          :license_evaluation,
          cookbook_name: cookbook.name,
          cookbook_version: version.version,
          license_failure: false,
          license_feedback: 'This cookbook does not exist.',
          fieri_key: 'not_the_key',
          format: :json
        )

        expect(response.status.to_i).to eql(401)
        expect(JSON.parse(response.body)).to eql(
          'error_code' => I18n.t('api.error_codes.unauthorized'),
          'error_messages' => [
            I18n.t('api.error_messages.unauthorized_post_error')
          ]
        )
      end
    end
  end

  context 'when a metric result already exists' do
    let(:cookbook) { create(:cookbook) }
    let!(:version) { create(:cookbook_version, cookbook: cookbook) }
    let(:foodcritic_metric) { QualityMetric.foodcritic_metric }
    let!(:metric_result) do
      create(:metric_result, cookbook_version: version, quality_metric: foodcritic_metric)
    end

    before do
      expect(version.metric_results.where(cookbook_version: version, quality_metric: foodcritic_metric)).to_not be_empty
    end

    it 'deletes the old metric' do
      post(
        :foodcritic_evaluation,
        cookbook_name: cookbook.name,
        cookbook_version: version.to_param,
        foodcritic_failure: true,
        foodcritic_feedback: 'E066',
        fieri_key: 'YOUR_FIERI_KEY',
        format: :json
      )

      version.reload
      expect(version.metric_results).to_not include(metric_result)
    end

    it 'creates the new metric' do
      post(
        :foodcritic_evaluation,
        cookbook_name: cookbook.name,
        cookbook_version: version.to_param,
        foodcritic_failure: true,
        foodcritic_feedback: 'E066',
        fieri_key: 'YOUR_FIERI_KEY',
        format: :json
      )

      version.reload
      expect(version.metric_results.where(cookbook_version: version, quality_metric: foodcritic_metric)).to_not be_empty
    end

  end
end
