require 'spec_helper'

describe CookbooksController do
  let(:cookbook) do
    cookbook = create(:cookbook)
  end

  describe '#show' do
    it 'renders the show template' do
      get :show, id: cookbook.name

      expect(response).to render_template('show')
    end

    it 'sends the cookbook to the view' do
      get :show, id: cookbook.name

      expect(assigns(:cookbook)).to eql(cookbook)
    end

    it 'sends the latest cookbook version to the view' do
      version = create(:cookbook_version, cookbook: cookbook)
      get :show, id: cookbook.name

      expect(assigns(:latest_version)).to eql(version)
    end

    it '404s when the cookbook does not exist' do
      get :show, id: 'snarfle'

      expect(response.status.to_i).to eql(404)
    end
  end

  describe '#download' do
    it '302s to the cookbook version download  path' do
      version = create(:cookbook_version, cookbook: cookbook)

      get :download, id: cookbook.name

      expect(response).to redirect_to(cookbook_version_download_url(cookbook, version))
      expect(response.status.to_i).to eql(302)
    end

    it '404s when the cookbook does not exist' do
      get :download, id: 'snarfle'

      expect(response.status.to_i).to eql(404)
    end
  end
end
