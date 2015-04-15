require 'spec_helper'

describe CookbookVersionsController do
  describe '#download' do
    let(:cookbook) { create(:cookbook) }
    let(:version) { create(:cookbook_version, cookbook: cookbook) }
    let(:user) { create(:user) }
    before { sign_in user }

    it '302s to the latest cookbook version file' do
      get :download, cookbook_id: cookbook.name, version: version.to_param

      expect(response).to redirect_to(version.tarball.url)
      expect(response.status.to_i).to eql(302)
    end

    it 'logs the web download count for the cookbook version' do
      expect do
        get :download, cookbook_id: cookbook.name, version: version.to_param
      end.to change { version.reload.web_download_count }.by(1)
    end

    it 'logs the web download count for the cookbook' do
      expect do
        get :download, cookbook_id: cookbook.name, version: version.to_param
      end.to change { cookbook.reload.web_download_count }.by(1)
    end

    it '404s when the cookbook does not exist' do
      get :download, cookbook_id: 'snarfle', version: '100.1.1'

      expect(response.status.to_i).to eql(404)
    end

    it '404s when the cookbook version does not exist' do
      get :download, cookbook_id: cookbook.name, version: '100.1.1'

      expect(response.status.to_i).to eql(404)
    end

    context 'creating urls to cookbooks' do
      let(:mock_tarball) { version.tarball }

      before do
        allow(Cookbook).to receive_message_chain(:with_name, :first!).and_return(cookbook)
        allow(cookbook).to receive(:get_version!).and_return(version)
        allow(version).to receive(:tarball).and_return(mock_tarball)

      end

      context 'when using expiring urls' do
        before do
          ENV['S3_URLS_EXPIRE'] = '10'
        end

        it 'redirects to the expiring url' do
          expect(version.tarball).to receive(:expiring_url)
            .with(ENV['S3_URLS_EXPIRE'])
            .and_return(version.tarball.expiring_url(ENV['S3_URLS_EXPIRE']))

          get :download, cookbook_id: cookbook.name, version: version.to_param
        end

        after do
          ENV['S3_URLS_EXPIRE'] = nil
        end
      end

      context 'when not using a private s3 bucked' do
        it 'redirects to the url for the cookbook' do
          expect(mock_tarball).to_not receive(:expiring_url)
          expect(mock_tarball).to receive(:url).and_return(version.tarball.url)

          get :download, cookbook_id: cookbook.name, version: version.to_param
        end
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
      get :show, cookbook_id: cookbook.name, version: version.version

      expect(assigns(:cookbook)).to_not be_nil
    end

    it 'provides the cookbook version to the view' do
      get :show, cookbook_id: cookbook.name, version: version.version

      expect(assigns(:version)).to_not be_nil
    end

    it "provides all of the cookbook's versions to the view" do
      get :show, cookbook_id: cookbook.name, version: version.version

      expect(assigns(:cookbook_versions)).to_not be_nil
    end

    it "provides the cookbook's maintainer to the view" do
      get :show, cookbook_id: cookbook.name, version: version.version

      expect(assigns(:owner)).to_not be_nil
    end

    it "provides the cookbook's collaborators to the view" do
      get :show, cookbook_id: cookbook.name, version: version.version

      expect(assigns(:collaborators)).to_not be_nil
    end

    it "provides this versions's supported_platforms to the view" do
      version.supported_platforms.create!(name: 'one')
      version.supported_platforms.create!(name: 'two')

      get :show, cookbook_id: cookbook.name, version: version.version

      expect(assigns(:supported_platforms).map(&:name)).
        to match_array(%w(one two))
    end
  end
end
