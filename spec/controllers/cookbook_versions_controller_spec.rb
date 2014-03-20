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
end
