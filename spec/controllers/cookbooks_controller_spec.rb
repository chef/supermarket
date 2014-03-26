require 'spec_helper'

describe CookbooksController do
  describe 'GET #index' do
    context 'there are no parameters' do
      it 'assigns @cookbooks' do
        get :index
        expect(assigns[:cookbooks]).to_not be_nil
      end

      it 'paginates @cookbooks' do
        create_list(:cookbook, 30)
        get :index

        expect(assigns[:cookbooks].count).to eql(20)
      end

      it 'assigns @categories' do
        get :index
        expect(assigns[:categories]).to_not be_nil
      end
    end

    context 'there is an order parameter' do
      let!(:cookbook_1) { create(:cookbook, updated_at: 1.year.ago, created_at: 1.year.ago) }
      let!(:cookbook_2) { create(:cookbook, updated_at: 1.day.ago, created_at: 2.years.ago) }

      it 'orders @cookbooks by updated at' do
        get :index, order: 'recently_updated'
        expect(assigns[:cookbooks].first).to eql(cookbook_2)
      end

      it 'orders @cookbooks by created at' do
        get :index, order: 'created_at'
        expect(assigns[:cookbooks].first).to eql(cookbook_1)
      end
    end

    context 'there is a category parameter' do
      let!(:databases_cookbook) { create(:cookbook, category: create(:category, name: 'Databases')) }
      let!(:other_cookbook) { create(:cookbook, category: create(:category, name: 'Other')) }

      it 'only returns @cookbooks with the specified category' do
        get :index, category: 'other'

        expect(assigns[:cookbooks]).to include(other_cookbook)
        expect(assigns[:cookbooks]).to_not include(databases_cookbook)
      end
    end

    context 'there is a query parameter' do
      let!(:amazing_cookbook) do
        create(
          :cookbook,
          name: 'Amazing Cookbook',
          maintainer: 'john@example.com',
          description: 'Makes you a pirate',
          category: create(:category, name: 'Databases')
        )
      end

      let!(:ok_cookbook) do
        create(
          :cookbook,
          name: 'OK Cookbook',
          maintainer: 'jack@example.com',
          description: 'Makes you a pigeon',
          category: create(:category, name: 'Other')
        )
      end

      it 'only returns @cookbooks that match the name' do
        get :index, q: 'amazing'

        expect(assigns[:cookbooks]).to include(amazing_cookbook)
        expect(assigns[:cookbooks]).to_not include(ok_cookbook)
      end

      it 'only returns @cookbooks that match the maintainer' do
        get :index, q: 'john'

        expect(assigns[:cookbooks]).to include(amazing_cookbook)
        expect(assigns[:cookbooks]).to_not include(ok_cookbook)
      end

      it 'only returns @cookbooks that match the description' do
        get :index, q: 'pirate'

        expect(assigns[:cookbooks]).to include(amazing_cookbook)
        expect(assigns[:cookbooks]).to_not include(ok_cookbook)
      end

      it 'only returns @cookbooks that match the category' do
        get :index, q: 'databases'

        expect(assigns[:cookbooks]).to include(amazing_cookbook)
        expect(assigns[:cookbooks]).to_not include(ok_cookbook)
      end
    end
  end

  describe 'PATCH #update' do
    let(:cookbook) { create(:cookbook) }

    it 'updates the cookbook' do
      patch :update, id: cookbook.name, cookbook: {
        source_url: 'http://example.com/cookbook',
        issues_url: 'http://example.com/cookbook/issues'
      }
      cookbook.reload

      expect(cookbook.source_url).to eql('http://example.com/cookbook')
      expect(cookbook.issues_url).to eql('http://example.com/cookbook/issues')
    end

    # maybe this should be 'returns the cookbook on success'
    it 'returns a 200 on success'  do
      patch :update, id: cookbook.name, cookbook: {
        source_url: 'http://example.com/cookbook',
        issues_url: 'http://example.com/cookbook/issues'
      }
      cookbook.reload

      expect(response.status.to_i).to eql(200)
    end

    it 'returns cookbook on success'  do
      patch :update, id: cookbook.name, cookbook: {
        source_url: 'http://example.com/cookbook',
        issues_url: 'http://example.com/cookbook/issues'
      }
      cookbook.reload

      expect(response.body).to include(cookbook.to_json)
    end

    it 'returns error messages on failure'
    it 'returns a 404 when cookbook not found'
  end

  describe 'GET #directory' do
    before { get :directory }

    it 'assigns @recently_updated_cookbooks' do
      expect(assigns[:recently_updated_cookbooks]).to_not be_nil
    end

    it 'assigns @recently_added_cookbooks' do
      expect(assigns[:recently_added_cookbooks]).to_not be_nil
    end

    it 'assigns @categories' do
      expect(assigns[:categories]).to_not be_nil
    end
  end

  describe '#show' do
    let(:cookbook) do
      create(:cookbook)
    end

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

    it 'sends all cookbook versions to the view' do
      get :show, id: cookbook.name

      expect(assigns(:cookbook_versions)).to_not be_empty
    end

    it 'sends the maintainer to the view' do
      create(:user) # TODO: remove this once cookbooks have a maintainer

      get :show, id: cookbook.name

      expect(assigns(:maintainer)).to_not be_nil
    end

    it 'sends the collaborators to the view' do
      create(:user) # TODO: remove this once cookbooks have a maintainer

      get :show, id: cookbook.name

      expect(assigns(:collaborators)).to_not be_nil
    end

    it 'sends the supported platforms to the view' do
      get :show, id: cookbook.name

      expect(assigns(:supported_platforms)).to_not be_nil
    end

    it '404s when the cookbook does not exist' do
      get :show, id: 'snarfle'

      expect(response.status.to_i).to eql(404)
    end
  end

  describe '#download' do
    let(:cookbook) do
      cookbook = create(:cookbook)
    end

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
