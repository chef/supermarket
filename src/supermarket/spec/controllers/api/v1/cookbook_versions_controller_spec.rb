require 'spec_helper'

describe Api::V1::CookbookVersionsController do
  describe '#show' do
    let!(:redis) { create(:cookbook, name: 'redis') }

    let!(:redis_0_1_2) do
      create(:cookbook_version, cookbook: redis, version: '0.1.2')
    end

    let!(:redis_1_0_0) do
      create(:cookbook_version, cookbook: redis, version: '1.0.0')
    end

    it 'responds with a 200' do
      get :show, cookbook: 'redis', version: 'latest', format: :json

      expect(response.status.to_i).to eql(200)
    end

    it 'sends the cookbook to the view' do
      get :show, cookbook: 'redis', version: 'latest', format: :json

      expect(assigns[:cookbook]).to eql(redis)
    end

    it 'sends the cookbook version to the view' do
      get :show, cookbook: 'redis', version: '1.0.0', format: :json

      expect(assigns[:cookbook_version]).to eql(redis_1_0_0)
    end

    it 'includes the cookbook version\'s metric results' do
      qm = create(:foodcritic_metric)
      metric_result = create(:metric_result,
                             cookbook_version: redis_1_0_0,
                             quality_metric: qm
                            )

      get :show, cookbook: 'redis', version: '1.0.0', format: :json

      expect(assigns[:cookbook_version_metrics]).to include(metric_result)
    end

    it 'handles the latest version of a cookbook' do
      latest_version = redis.latest_cookbook_version
      get :show, cookbook: 'redis', version: 'latest', format: :json

      expect(assigns[:cookbook_version]).to eql(latest_version)
    end

    it 'handles specific versions of a cookbook' do
      get :show, cookbook: 'redis', version: '0_1_2', format: :json

      expect(assigns[:cookbook_version]).to eql(redis_0_1_2)
    end

    it '404s if a cookbook version does not exist' do
      get :show, cookbook: 'redis', version: '4_0_2', format: :json

      expect(response.status.to_i).to eql(404)
    end
  end

  describe '#download' do
    let(:cookbook) { create(:cookbook) }
    let(:version) { create(:cookbook_version, cookbook: cookbook) }

    it '302s to the cookbook version file URL' do
      get :download, cookbook: cookbook.name, version: version.to_param, format: :json

      expect(response).to redirect_to(version.tarball.url)
      expect(response.status.to_i).to eql(302)
    end

    it 'logs the web download count for the cookbook version' do
      expect do
        get :download, cookbook: cookbook.name, version: version.to_param, format: :json
      end.to change { version.reload.api_download_count }.by(1)
    end

    it 'logs the web download count for the cookbook' do
      expect do
        get :download, cookbook: cookbook.name, version: version.to_param, format: :json
      end.to change { cookbook.reload.api_download_count }.by(1)
    end

    it '404s when the cookbook does not exist' do
      get :download, cookbook: 'snarfle', version: '100.1.1', format: :json

      expect(response.status.to_i).to eql(404)
    end

    it '404s when the cookbook version does not exist' do
      get :download, cookbook: cookbook.name, version: '100.1.1', format: :json

      expect(response.status.to_i).to eql(404)
    end
  end

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
            publish_failure: false,
            publish_feedback: '',
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
end
