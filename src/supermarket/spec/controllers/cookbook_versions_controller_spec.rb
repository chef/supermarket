require 'spec_helper'

describe CookbookVersionsController do
  describe '#index' do
    let(:cookbook) { create(:cookbook) }
    let(:version) { create(:cookbook_version, cookbook: cookbook) }

    it 'responds to a GET' do
      get :index
      expect(assigns[:cookbook_versions]).to_not be_nil
    end
  end

  describe '#download' do
    let(:cookbook) { create(:cookbook) }
    let(:version) { create(:cookbook_version, cookbook: cookbook) }
    let(:user) { create(:user) }
    before { sign_in user }

    it '302s to the latest cookbook version file' do
      get :download, params: { cookbook_id: cookbook.name, version: version.to_param }

      expect(response).to redirect_to(version.cookbook_artifact_url)
      expect(response.status.to_i).to eql(302)
    end

    it 'logs the web download count for the cookbook version' do
      expect do
        get :download, params: { cookbook_id: cookbook.name, version: version.to_param }
      end.to change { version.reload.web_download_count }.by(1)
    end

    it 'logs the web download count for the cookbook' do
      expect do
        get :download, params: { cookbook_id: cookbook.name, version: version.to_param }
      end.to change { cookbook.reload.web_download_count }.by(1)
    end

    it '404s when the cookbook does not exist' do
      get :download, params: { cookbook_id: 'snarfle', version: '100.1.1' }

      expect(response.status.to_i).to eql(404)
    end

    it '404s when the cookbook version does not exist' do
      get :download, params: { cookbook_id: cookbook.name, version: '100.1.1' }

      expect(response.status.to_i).to eql(404)
    end

    context 'creating urls to cookbooks' do
      let(:mock_tarball) { version.tarball }

      before do
        allow(Cookbook).to receive_message_chain(:with_name, :first!).and_return(cookbook)
        allow(cookbook).to receive(:get_version!).and_return(version)
        allow(version).to receive(:tarball).and_return(mock_tarball)
      end

      it 'calls for the artifact url' do
        expect(version).to receive(:cookbook_artifact_url).and_return(version.cookbook_artifact_url)
        get :download, params: { cookbook_id: cookbook.name, version: version.to_param }
      end
    end
  end

  describe '#show' do
    let(:cookbook) { create(:cookbook) }
    let(:version) { cookbook.cookbook_versions.first }

    before do
      create(:cookbook_version, cookbook: cookbook)
    end

    it 'provides the cookbook to the view' do
      get :show, params: { cookbook_id: cookbook.name, version: version.version }

      expect(assigns(:cookbook)).to_not be_nil
    end

    it 'provides the cookbook version to the view' do
      get :show, params: { cookbook_id: cookbook.name, version: version.version }

      expect(assigns(:version)).to_not be_nil
    end

    it "provides all of the cookbook's versions to the view" do
      get :show, params: { cookbook_id: cookbook.name, version: version.version }

      expect(assigns(:cookbook_versions)).to_not be_nil
    end

    it "provides the cookbook's maintainer to the view" do
      get :show, params: { cookbook_id: cookbook.name, version: version.version }

      expect(assigns(:owner)).to_not be_nil
    end

    it "provides the cookbook's collaborators to the view" do
      get :show, params: { cookbook_id: cookbook.name, version: version.version }

      expect(assigns(:collaborators)).to_not be_nil
    end

    it "provides this versions's supported_platforms to the view" do
      version.supported_platforms.create!(name: 'one')
      version.supported_platforms.create!(name: 'two')

      get :show, params: { cookbook_id: cookbook.name, version: version.version }

      expect(assigns(:supported_platforms).map(&:name)).
        to match_array(%w[one two])
    end

    context 'displaying metrics' do
      let(:foodcritic_qm) { create(:foodcritic_metric) }
      let(:collab_num_qm) { create(:collaborator_num_metric) }
      let(:publish_qm) { create(:publish_metric, admin_only: true) }

      let(:foodcritic_result) do
        create(:metric_result,
               cookbook_version: version,
               quality_metric:   foodcritic_qm,
               failure:          true,
               feedback:         'it failed')
      end

      let(:collab_result) do
        create(:metric_result,
               cookbook_version: version,
               quality_metric:   collab_num_qm,
               failure:          false,
               feedback:         'it passed')
      end

      let(:publish_result) do
        create(:metric_result,
               cookbook_version: version,
               quality_metric:   publish_qm,
               failure:          false,
               feedback:         'it passed')
      end

      before do
        expect(version.metric_results).to include(foodcritic_result, collab_result, publish_result)
      end

      context 'public metrics' do
        it 'sends the public metrics results to the view' do
          get :show, params: { cookbook_id: cookbook.name, version: version.version }
          expect(assigns(:public_metric_results)).to include(foodcritic_result, collab_result)
        end

        it 'does not include the admin only metrics' do
          get :show, params: { cookbook_id: cookbook.name, version: version.version }
          expect(assigns(:public_metric_results)).to_not include(publish_result)
        end
      end

      context 'admin only metrics' do
        it 'sends the admin only metrics to the view' do
          get :show, params: { cookbook_id: cookbook.name, version: version.version }
          expect(assigns(:admin_metric_results)).to include(publish_result)
        end

        it 'does not include the public metrics' do
          get :show, params: { cookbook_id: cookbook.name, version: version.version }
          expect(assigns(:admin_metric_results)).to_not include(foodcritic_result, collab_result)
        end
      end
    end
  end
end
