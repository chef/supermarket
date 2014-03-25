require 'spec_helper'

describe CookbookVersionsController do
  describe '#download' do
    let(:cookbook) { create(:cookbook) }
    let(:version) { create(:cookbook_version, cookbook: cookbook) }

    it '302s to the latest cookbook version file' do
      get :download, cookbook_id: cookbook.name, version: version.to_param

      expect(response).to redirect_to(version.tarball.url)
      expect(response.status.to_i).to eql(302)
    end

    it 'logs the download count for the cookbook version' do
      expect do
        get :download, cookbook_id: cookbook.name, version: version.to_param
      end.to change { version.reload.download_count }.by(1)
    end

    it 'logs the download count for the cookbook' do
      expect do
        get :download, cookbook_id: cookbook.name, version: version.to_param
      end.to change { cookbook.reload.download_count }.by(1)
    end

    it '404s when the cookbook does not exist' do
      get :download, cookbook_id: 'snarfle', version: '100.1.1'

      expect(response.status.to_i).to eql(404)
    end

    it '404s when the cookbook version does not exist' do
      get :download, cookbook_id: cookbook.name, version: '100.1.1'

      expect(response.status.to_i).to eql(404)
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
      create(:user) # TODO: replace with real maintainer

      get :show, cookbook_id: cookbook.name, version: version.version

      expect(assigns(:maintainer)).to_not be_nil
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
