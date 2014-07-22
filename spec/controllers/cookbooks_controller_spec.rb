require 'spec_helper'

describe CookbooksController do
  describe 'GET #index' do
    context 'there are no parameters' do
      let!(:postgresql) { create(:cookbook, name: 'postgresql') }
      let!(:mysql) { create(:cookbook, name: 'mysql') }

      it 'assigns @cookbooks' do
        get :index
        expect(assigns[:cookbooks]).to_not be_nil
      end

      it 'orders @cookbooks alphabetically by name' do
        get :index
        expect(assigns[:cookbooks][0]).to eql(mysql)
        expect(assigns[:cookbooks][1]).to eql(postgresql)
      end

      it 'assigns @number_of_cookbooks' do
        get :index
        expect(assigns[:number_of_cookbooks]).to_not be_nil
      end
    end

    context 'there is an order parameter' do
      let!(:cookbook_1) do
        create(
          :cookbook,
          name: 'mysql',
          web_download_count: 1,
          api_download_count: 100,
          cookbook_followers_count: 100
        )
      end

      let!(:cookbook_2) do
        create(
          :cookbook,
          name: 'mysql-admin-tools',
          web_download_count: 1,
          api_download_count: 50,
          cookbook_followers_count: 50
        )
      end

      it 'orders @cookbooks by updated at' do
        cookbook_2.touch
        get :index, order: 'recently_updated'
        expect(assigns[:cookbooks].first).to eql(cookbook_2)
      end

      it 'orders @cookbooks with the most recently created first' do
        get :index, order: 'recently_added'
        expect(assigns[:cookbooks].first).to eql(cookbook_2)
      end

      it 'orders @cookbooks by their download count' do
        get :index, order: 'most_followed'
        expect(assigns[:cookbooks].first).to eql(cookbook_1)
      end

      it 'orders @cookbooks by download_followers_count' do
        get :index, order: 'most_downloaded'
        expect(assigns[:cookbooks].first).to eql(cookbook_1)
      end

      it 'correctly orders @cookbooks when also searching' do
        get :index, order: 'most_followed', q: 'mysql'
        expect(assigns[:cookbooks].first).to eql(cookbook_1)
      end
    end

    context 'there is a query parameter' do
      let!(:amazing_cookbook) do
        create(
          :cookbook,
          name: 'AmazingCookbook',
          category: create(:category, name: 'Databases')
        )
      end

      let!(:ok_cookbook) do
        create(
          :cookbook,
          name: 'OKCookbook',
          category: create(:category, name: 'Other')
        )
      end

      it 'only returns @cookbooks that match the query parameter' do
        get :index, q: 'amazing'

        expect(assigns[:cookbooks]).to include(amazing_cookbook)
        expect(assigns[:cookbooks]).to_not include(ok_cookbook)
      end
    end
  end

  describe 'PATCH #update' do
    let(:user) { create(:user) }
    let(:cookbook) { create(:cookbook, owner: user) }
    before { sign_in user }

    context 'the params are valid' do
      it 'updates the cookbook' do
        patch :update, id: cookbook, cookbook: {
          source_url: 'http://example.com/cookbook',
          issues_url: 'http://example.com/cookbook/issues'
        }

        cookbook.reload

        expect(cookbook.source_url).to eql('http://example.com/cookbook')
        expect(cookbook.issues_url).to eql('http://example.com/cookbook/issues')
      end

      it 'redirects to @cookbook'  do
        patch :update, id: cookbook, cookbook: {
          source_url: 'http://example.com/cookbook',
          issues_url: 'http://example.com/cookbook/issues'
        }

        expect(response).to redirect_to(assigns[:cookbook])
      end
    end

    context 'the params are invalid' do
      it "doesn't update the cookbook" do
        expect do
          patch :update, id: cookbook, cookbook: { source_url: 'some-invalid-url' }
        end.to_not change(cookbook, :source_url)
      end

      it 'redirects to @cookbook' do
        patch :update, id: cookbook, cookbook: { source_url: 'some-invalid-url' }

        expect(response).to redirect_to(assigns[:cookbook])
      end
    end
  end

  describe 'GET #directory' do
    before { get :directory }

    it 'assigns @recently_updated_cookbooks' do
      expect(assigns[:recently_updated_cookbooks]).to_not be_nil
    end

    it 'assigns @most_downloaded_cookbooks' do
      expect(assigns[:most_downloaded_cookbooks]).to_not be_nil
    end

    it 'assigns @most_followed_cookbooks' do
      expect(assigns[:most_followed_cookbooks]).to_not be_nil
    end

    it 'assigns @categories' do
      expect(assigns[:categories]).to_not be_nil
    end

    it 'sends cookbook count to the view' do
      expect(assigns[:cookbook_count]).to_not be_nil
    end

    it 'sends user count to the view' do
      expect(assigns[:user_count]).to_not be_nil
    end
  end

  describe '#show' do
    let(:hank) { create(:user) }
    let(:sally) { create(:user) }
    let(:cookbook) { create(:cookbook, owner: hank) }

    it 'renders the show template' do
      get :show, id: cookbook.name

      expect(response).to render_template('show')
    end

    it 'renders an atom feed of cookbook versions' do
      get :show, id: cookbook.name, format: :atom

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
      get :show, id: cookbook.name

      expect(assigns(:owner)).to_not be_nil
    end

    it 'sends the collaborators to the view' do
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

  describe 'PUT #follow' do
    let(:cookbook) { create(:cookbook) }

    context 'a user is signed in' do
      before { sign_in create(:user) }

      it 'should add a follower' do
        expect do
          put :follow, id: cookbook
        end.to change(cookbook.cookbook_followers, :count).by(1)
      end

      it 'returns a 200' do
        put :follow, id: cookbook

        expect(response.status.to_i).to eql(200)
      end

      it 'renders the show follow button partial' do
        put :follow, id: cookbook

        expect(response).to render_template('cookbooks/_follow_button_show')
      end

      it 'renders the list follow button partial if the list param is present' do
        put :follow, id: cookbook, list: true

        expect(response).to render_template('cookbooks/_follow_button_list')
      end
    end

    context 'a user is not signed in' do
      it 'redirects to user sign in' do
        put :follow, id: cookbook

        expect(response).to redirect_to(sign_in_path)
      end
    end

    context 'cookbook does not exist' do
      before { sign_in create(:user) }

      it 'returns a 404' do
        put :follow, id: 'snarfle'

        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe 'DELETE #unfollow' do
    let(:cookbook) { create(:cookbook) }

    context 'the signed in user follows the specified cookbook' do
      before do
        user = create(:user)
        create(:cookbook_follower, cookbook: cookbook, user: user)
        sign_in(user)
      end

      it 'should remove follower' do
        expect do
          delete :unfollow, id: cookbook
        end.to change(cookbook.cookbook_followers, :count).by(-1)
      end

      it 'redirects 200' do
        delete :follow, id: cookbook

        expect(response.status.to_i).to eql(200)
      end

      it 'renders the show follow button partial' do
        delete :follow, id: cookbook

        expect(response).to render_template('cookbooks/_follow_button_show')
      end

      it 'renders the list follow button partial if the list param is present' do
        put :follow, id: cookbook, list: true

        expect(response).to render_template('cookbooks/_follow_button_list')
      end
    end

    context "the signed in user doesn't follow the specified cookbook" do
      before { sign_in create(:user) }

      it 'should not remove a follower'  do
        expect do
          delete :unfollow, id: cookbook
        end.to_not change(cookbook.cookbook_followers, :count)
      end

      it 'returns a 404' do
        delete :unfollow, id: cookbook

        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe 'PUT #transfer_ownership' do
    let(:cookbook) { create(:cookbook) }
    let(:new_owner) { create(:user) }

    context 'the current user is an admin' do
      before { sign_in(create(:admin)) }

      it 'changes the cookbooks owner' do
        put :transfer_ownership, id: cookbook, cookbook: { user_id: new_owner.id }
        cookbook.reload
        expect(cookbook.owner).to eql(new_owner)
      end

      it 'redirects back to the cookbook' do
        put :transfer_ownership, id: cookbook, cookbook: { user_id: new_owner.id }
        expect(response).to redirect_to(assigns[:cookbook])
      end
    end

    context 'the current user is not an admin' do
      before { sign_in(create(:user)) }

      it 'returns a 404' do
        put :transfer_ownership, id: cookbook, cookbook: { user_id: new_owner.id }
        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe 'PUT #deprecate' do
    let(:user) { create(:user) }
    let(:cookbook) { create(:cookbook, owner: user) }
    let(:replacement_cookbook) { create(:cookbook) }

    context 'cookbook owner' do
      before { sign_in(user) }

      it 'deprecates the cookbook and sets the replacement' do
        put(
          :deprecate,
          id: cookbook,
          cookbook: {
            replacement: replacement_cookbook
          }
        )

        cookbook.reload

        expect(cookbook.deprecated).to eql(true)
        expect(cookbook.replacement).to eql(replacement_cookbook)
      end

      it 'redirects back to the cookbook' do
        put(
          :deprecate,
          id: cookbook,
          cookbook: {
            replacement: replacement_cookbook
          }
        )

        expect(response).to redirect_to(cookbook)
      end

      it 'starts the cookbook deprecated notifier worker' do
        expect do
          put(
            :deprecate,
            id: cookbook,
            cookbook: {
              replacement: replacement_cookbook
            }
          )
        end.to change(CookbookDeprecatedNotifier.jobs, :size).by(1)
      end
    end

    context 'not the cookbook owner' do
      before { sign_in(create(:user)) }

      it 'returns a 404' do
        put(
          :deprecate,
          id: cookbook,
          cookbook: {
            replacement: replacement_cookbook
          }
        )

        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe 'PUT #toggle_featured' do
    let(:admin) { create(:admin) }
    let(:unfeatured) { create(:cookbook, featured: false) }
    let(:featured) { create(:cookbook, featured: true) }
    before { sign_in(admin) }

    it 'sets a cookbook as featured if it is not already featured' do
      put :toggle_featured, id: unfeatured

      unfeatured.reload
      expect(unfeatured.featured).to eql(true)
    end

    it 'sets a cookbook as not featured if it is already featured' do
      put :toggle_featured, id: featured

      featured.reload
      expect(featured.featured).to eql(false)
    end

    it 'redirects back to the cookbook' do
      put :toggle_featured, id: unfeatured

      expect(response).to redirect_to(unfeatured)
    end

    it '404s if the user is not authorized to edit the tool' do
      sign_in(create(:user))

      put :toggle_featured, id: unfeatured

      expect(response.status.to_i).to eql(404)
    end
  end
end
