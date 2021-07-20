require "spec_helper"

describe CookbooksController do
  describe "GET #index" do
    context "there are no parameters" do
      let!(:postgresql) { create(:cookbook, name: "postgresql") }
      let!(:mysql) { create(:cookbook, name: "mysql") }
      let!(:dep_cookbook) { create(:cookbook, name: "dep_cookbook", deprecated: :true) }

      it "assigns @cookbooks" do
        get :index
        expect(assigns[:cookbooks]).to_not be_nil
      end

      it "orders @cookbooks alphabetically by name" do
        get :index
        expect(assigns[:cookbooks][0]).to eql(mysql)
        expect(assigns[:cookbooks][1]).to eql(postgresql)
      end

      it "assigns @number_of_cookbooks" do
        get :index
        expect(assigns[:number_of_cookbooks]).to_not be_nil
      end

      it "orders @cookbooks by deprecated flag" do
        get :index
        expect(assigns[:cookbooks][0]).to eql(mysql)
        expect(assigns[:cookbooks][1]).to eql(postgresql)
        expect(assigns[:cookbooks][2]).to eql(dep_cookbook)
      end
    end

    context "there is an order parameter" do
      let!(:cookbook_1) do
        create(
          :cookbook,
          name: "mysql",
          web_download_count: 1,
          api_download_count: 100,
          cookbook_followers_count: 100
        )
      end

      let!(:cookbook_2) do
        create(
          :cookbook,
          name: "mysql-admin-tools",
          web_download_count: 1,
          api_download_count: 50,
          cookbook_followers_count: 50
        )
      end

      it "orders @cookbooks by updated at" do
        cookbook_2.touch
        get :index, params: { order: "recently_updated" }
        expect(assigns[:cookbooks].first).to eql(cookbook_2)
      end

      it "orders @cookbooks with the most recently created first" do
        get :index, params: { order: "recently_added" }
        expect(assigns[:cookbooks].first).to eql(cookbook_2)
      end

      it "orders @cookbooks by their download count" do
        get :index, params: { order: "most_followed" }
        expect(assigns[:cookbooks].first).to eql(cookbook_1)
      end

      it "orders @cookbooks by download_followers_count" do
        get :index, params: { order: "most_downloaded" }
        expect(assigns[:cookbooks].first).to eql(cookbook_1)
      end

      it "correctly orders @cookbooks when also searching" do
        get :index, params: { order: "most_followed", q: "mysql" }
        expect(assigns[:cookbooks].first).to eql(cookbook_1)
      end
    end

    context "there is a featured parameter" do
      let!(:featured) { create(:cookbook, featured: true) }
      let!(:unfeatured) { create(:cookbook, featured: false) }

      it "only returns @cookbooks that are featured" do
        get :index, params: { featured: true }

        expect(assigns[:cookbooks]).to include(featured)
        expect(assigns[:cookbooks]).to_not include(unfeatured)
      end
    end

    context "there is a query parameter" do
      let!(:amazing_cookbook) do
        create(
          :cookbook,
          name: "AmazingCookbook",
          category: create(:category, name: "Databases")
        )
      end

      let!(:ok_cookbook) do
        create(
          :cookbook,
          name: "OKCookbook",
          category: create(:category, name: "Other")
        )
      end

      it "only returns @cookbooks that match the query parameter" do
        get :index, params: { q: "amazing" }

        expect(assigns[:cookbooks]).to include(amazing_cookbook)
        expect(assigns[:cookbooks]).to_not include(ok_cookbook)
      end
    end

    context "there is a platform parameter" do
      let!(:debian_platform) do
        create(
          :supported_platform,
          name: "debian"
        )
      end

      let!(:erlang) do
        create(
          :cookbook,
          name: "erlang",
          cookbook_versions: [
            create(
              :cookbook_version,
              supported_platforms: [
                debian_platform,
                create(:supported_platform, name: "ubuntu"),
              ]
            ),
          ]
        )
      end

      let!(:ruby) do
        create(
          :cookbook,
          name: "ruby",
          cookbook_versions: [
            create(
              :cookbook_version,
              supported_platforms: [
                debian_platform,
                create(:supported_platform, name: "windows"),
              ]
            ),
          ]
        )
      end

      it "returns @cookbooks that support some of given platforms" do
        get :index, params: { platforms: %w{ubuntu windows} }
        expect(assigns[:cookbooks]).to include(erlang)
        expect(assigns[:cookbooks]).to include(ruby)
      end

      it "does not return @cookbooks that does not support any of given platforms" do
        get :index, params: { platforms: %w{windows} }
        expect(assigns[:cookbooks]).not_to include(erlang)
      end

      it "returns all @cookbooks if only blank platform is given" do
        get :index, params: { platforms: [""] }
        expect(assigns[:cookbooks]).to include(erlang)
        expect(assigns[:cookbooks]).to include(ruby)
      end

      it "works correctly with search" do
        get :index, params: { q: "ruby", platforms: %w{debian} }
        expect(assigns[:cookbooks]).to include(ruby)
        expect(assigns[:cookbooks]).not_to include(erlang)
      end

      it "works correctly with order" do
        erlang.update(web_download_count: 10, api_download_count: 100)
        ruby.update(web_download_count: 5, api_download_count: 101)

        get :index, params: { order: "most_downloaded", platforms: %w{debian} }
        expect(assigns[:cookbooks][0]).to eql(erlang)
        expect(assigns[:cookbooks][1]).to eql(ruby)
      end
    end

    context "when there is a badges parameter" do
      let!(:awesome_cookbook) { create(:partner_cookbook, name: "awesome_sauce") }
      let!(:but_not_saucy) { create(:partner_cookbook, name: "but_not_saucy") }
      let!(:unknown_cookbook) { create(:cookbook, name: "could_be_good_i_dunno") }

      it "returns cookbooks with badges" do
        get :index, params: { badges: %w{partner} }
        expect(assigns[:cookbooks]).to include(awesome_cookbook)
      end

      it "does not return cookbooks without badges" do
        get :index, params: { badges: %w{partner} }
        expect(assigns[:cookbooks]).not_to include(unknown_cookbook)
      end

      it "returns all cookbooks if not badges are given" do
        get :index, params: { badges: "" }
        expect(assigns[:cookbooks]).to include(awesome_cookbook)
        expect(assigns[:cookbooks]).to include(unknown_cookbook)
      end

      it "works correctly with search" do
        get :index, params: { q: "sauce", badges: %w{partner} }
        expect(assigns[:cookbooks]).to include(awesome_cookbook)
        expect(assigns[:cookbooks]).not_to include(but_not_saucy)
      end

      it "works correctly with order" do
        awesome_cookbook.update(web_download_count: 10, api_download_count: 100)
        but_not_saucy.update(web_download_count: 5, api_download_count: 101)

        get :index, params: { order: "most_downloaded", badges: %w{partner} }
        expect(assigns[:cookbooks][0]).to eql(awesome_cookbook)
        expect(assigns[:cookbooks][1]).to eql(but_not_saucy)
      end
    end
  end

  describe "POST #adoption" do
    let(:user) { create(:user) }
    let(:cookbook) { create(:cookbook) }

    it "requires authentication" do
      post :adoption, params: { id: cookbook }
      expect(response).to redirect_to(sign_in_url)
    end

    it "sends an adoption email to the cookbook owner" do
      sign_in user
      Sidekiq::Testing.inline! do
        post :adoption, params: { id: cookbook }
        expect(ActionMailer::Base.deliveries.map(&:to).flatten).to include(cookbook.owner.email)
      end
    end

    it "redirects to the @cookbook" do
      sign_in user
      post :adoption, params: { id: cookbook }
      expect(response).to redirect_to(assigns[:cookbook])
    end
  end

  describe "PATCH #update" do
    let(:user) { create(:user) }
    let(:cookbook) { create(:cookbook, owner: user) }
    let(:another_user) do
      create(
        :user,
        first_name: "Jane",
        last_name: "Doe",
        email: "jane@example.com"
      )
    end
    let!(:cookbook_follower) do
      create(
        :cookbook_follower,
        user: another_user,
        cookbook: cookbook
      )
    end
    before { sign_in user }

    context "the params are valid" do
      it "updates the cookbook" do
        patch :update, params: { id: cookbook, cookbook: {
          source_url: "http://example.com/cookbook",
          issues_url: "http://example.com/cookbook/issues",
          up_for_adoption: true,
        } }

        cookbook.reload

        expect(cookbook.source_url).to eql("http://example.com/cookbook")
        expect(cookbook.issues_url).to eql("http://example.com/cookbook/issues")
        expect(cookbook.up_for_adoption).to eql(true)
      end

      it "sends an adoption email to cookbook followers" do
        cookbook.reload
        Sidekiq::Testing.inline! do
          patch :update, params: { id: cookbook, cookbook: {
            source_url: "http://example.com/cookbook",
            issues_url: "http://example.com/cookbook/issues",
            up_for_adoption: "true",
          } }
          expect(ActionMailer::Base.deliveries.map(&:to).flatten).to include(cookbook_follower.user.email)
        end
      end

      it "redirects to @cookbook" do
        patch :update, params: { id: cookbook, cookbook: {
          source_url: "http://example.com/cookbook",
          issues_url: "http://example.com/cookbook/issues",
        } }

        expect(response).to redirect_to(assigns[:cookbook])
      end
    end

    context "the params are invalid" do
      it "doesn't update the cookbook" do
        expect do
          patch :update, params: { id: cookbook, cookbook: { source_url: "some-invalid-url" } }
        end.to_not change(cookbook, :source_url)
      end

      it "redirects to @cookbook" do
        patch :update, params: { id: cookbook, cookbook: { source_url: "some-invalid-url" } }

        expect(response).to redirect_to(assigns[:cookbook])
      end
    end
  end

  describe "GET #directory" do
    let!(:cookbook_1) do
      create(
        :cookbook,
        name: "mysql",
        web_download_count: 1,
        api_download_count: 100,
        cookbook_followers_count: 100,
        updated_at: Time.zone.now
      )
    end

    let!(:cookbook_2) do
      create(
        :cookbook,
        name: "mysql-admin-tools",
        web_download_count: 1,
        api_download_count: 50,
        cookbook_followers_count: 50,
        updated_at: Time.zone.now - 2.days
      )
    end

    let(:cookbook1_versionA) do
      create(
        :cookbook_version,
        cookbook: cookbook_1,
        created_at: Time.zone.now - 1.day
      )
    end

    let(:cookbook2_versionA) do
      create(
        :cookbook_version,
        cookbook: cookbook_2,
        created_at: Time.zone.now
      )
    end

    let(:cookbook2_versionB) do
      create(
        :cookbook_version,
        cookbook: cookbook_2,
        created_at: Time.zone.now
      )
    end

    before do
      CookbookVersion.destroy_all
    end

    it "assigns @recently_updated_cookbook" do
      get(:directory)
      expect(assigns[:recently_updated_cookbooks]).to_not be_nil
    end

    it "orders cookbooks by @recently_updated_cookbooks" do
      cookbook1_versionA
      cookbook2_versionA
      get(:directory)

      expect(assigns[:recently_updated_cookbooks].first).to eq(cookbook_2)
      expect(assigns[:recently_updated_cookbooks].last).to eq(cookbook_1)
    end

    it "returns unique cookbooks when ordered by @recently_updated_cookbooks" do
      cookbook1_versionA
      cookbook2_versionA
      cookbook2_versionB
      get(:directory)

      expect(assigns[:recently_updated_cookbooks]).to include(cookbook_1)
      expect(assigns[:recently_updated_cookbooks].length).to eq 2
    end

    it "assigns @most_downloaded_cookbooks" do
      get(:directory)
      expect(assigns[:most_downloaded_cookbooks]).to_not be_nil
    end

    it "assigns @most_followed_cookbooks" do
      get(:directory)
      expect(assigns[:most_followed_cookbooks]).to_not be_nil
    end

    it "assigns @featured_cookbooks" do
      get(:directory)
      expect(assigns[:featured_cookbooks]).to_not be_nil
    end

    it "sends cookbook count to the view" do
      get(:directory)
      expect(assigns[:cookbook_count]).to_not be_nil
    end

    it "sends user count to the view" do
      get(:directory)
      expect(assigns[:user_count]).to_not be_nil
    end
  end

  describe "#show" do
    let(:hank) { create(:user) }
    let(:sally) { create(:user) }
    let(:cookbook) { create(:cookbook, owner: hank) }

    it "renders the show template" do
      get :show, params: { id: cookbook.name }

      expect(response).to render_template("show")
    end

    it "renders an atom feed of cookbook versions" do
      get :show, params: { id: cookbook.name, format: :atom }

      expect(response).to render_template("show")
    end

    it "sends the cookbook to the view" do
      get :show, params: { id: cookbook.name }

      expect(assigns(:cookbook)).to eql(cookbook)
    end

    it "sends the latest cookbook version to the view" do
      version = create(:cookbook_version, cookbook: cookbook)
      get :show, params: { id: cookbook.name }

      expect(assigns(:latest_version)).to eql(version)
    end

    it "sends all cookbook versions to the view" do
      get :show, params: { id: cookbook.name }

      expect(assigns(:cookbook_versions)).to_not be_empty
    end

    it "sends the collaborators to the view" do
      get :show, params: { id: cookbook.name }

      expect(assigns(:collaborators)).to_not be_nil
    end

    it "sends the supported platforms to the view" do
      get :show, params: { id: cookbook.name }

      expect(assigns(:supported_platforms)).to_not be_nil
    end

    context "displaying metrics" do
      let(:foodcritic_qm) { create(:foodcritic_metric) }
      let(:collab_num_qm) { create(:collaborator_num_metric) }
      let(:publish_qm) { create(:publish_metric, admin_only: true) }

      let(:foodcritic_result) do
        create(:metric_result,
               cookbook_version: cookbook.latest_cookbook_version,
               quality_metric:   foodcritic_qm,
               failure:          true,
               feedback:         "it failed")
      end

      let(:collab_result) do
        create(:metric_result,
               cookbook_version: cookbook.latest_cookbook_version,
               quality_metric:   collab_num_qm,
               failure:          false,
               feedback:         "it passed")
      end

      let(:publish_result) do
        create(:metric_result,
               cookbook_version: cookbook.latest_cookbook_version,
               quality_metric:   publish_qm,
               failure:          false,
               feedback:         "it passed")
      end

      before do
        expect(cookbook.latest_cookbook_version.metric_results).to include(foodcritic_result, collab_result, publish_result)
      end

      context "public metrics" do
        it "sends the public metrics results to the view" do
          get :show, params: { id: cookbook.name }
          expect(assigns(:public_metric_results)).to include(foodcritic_result, collab_result)
        end

        it "does not include admin only metrics" do
          get :show, params: { id: cookbook.name }
          expect(assigns(:public_metric_results)).to_not include(publish_result)
        end
      end

      context "admin only metrics" do
        it "sends the admin only metrics to the view" do
          get :show, params: { id: cookbook.name }
          expect(assigns(:admin_metric_results)).to include(publish_result)
        end

        it "does not include the public metrics" do
          get :show, params: { id: cookbook.name }
          expect(assigns(:admin_metric_results)).to_not include(foodcritic_result, collab_result)
        end
      end
    end

    it "404s when the cookbook does not exist" do
      get :show, params: { id: "snarfle" }

      expect(response.status.to_i).to eql(404)
    end
  end

  describe "#download" do
    let(:cookbook) { create(:cookbook) }

    it "302s to the cookbook version download  path" do
      version = create(:cookbook_version, cookbook: cookbook)

      get :download, params: { id: cookbook.name }

      expect(response).to redirect_to(cookbook_version_download_url(cookbook, version))
      expect(response.status.to_i).to eql(302)
    end

    it "404s when the cookbook does not exist" do
      get :download, params: { id: "snarfle" }

      expect(response.status.to_i).to eql(404)
    end
  end

  describe "PUT #follow" do
    let(:cookbook) { create(:cookbook) }

    context "a user is signed in" do
      before { sign_in create(:user) }

      it "should add a follower" do
        expect do
          put :follow, params: { id: cookbook }
        end.to change(cookbook.cookbook_followers, :count).by(1)
      end

      it "returns a 200" do
        put :follow, params: { id: cookbook }

        expect(response.status.to_i).to eql(200)
      end

      it "renders the show follow button partial" do
        put :follow, params: { id: cookbook }

        expect(response).to render_template("cookbooks/_follow_button_show")
      end

      it "renders the list follow button partial if the list param is present" do
        put :follow, params: { id: cookbook, list: true }

        expect(response).to render_template("cookbooks/_follow_button_list")
      end
    end

    context "a user is not signed in" do
      it "redirects to user sign in" do
        put :follow, params: { id: cookbook }

        expect(response).to redirect_to(sign_in_path)
      end
    end

    context "cookbook does not exist" do
      before { sign_in create(:user) }

      it "returns a 404" do
        put :follow, params: { id: "snarfle" }

        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe "DELETE #unfollow" do
    let(:cookbook) { create(:cookbook) }

    context "the signed in user follows the specified cookbook" do
      before do
        user = create(:user)
        create(:cookbook_follower, cookbook: cookbook, user: user)
        sign_in(user)
      end

      it "should remove follower" do
        expect do
          delete :unfollow, params: { id: cookbook }
        end.to change(cookbook.cookbook_followers, :count).by(-1)
      end

      it "redirects 200" do
        delete :follow, params: { id: cookbook }

        expect(response.status.to_i).to eql(200)
      end

      it "renders the show follow button partial" do
        delete :follow, params: { id: cookbook }

        expect(response).to render_template("cookbooks/_follow_button_show")
      end

      it "renders the list follow button partial if the list param is present" do
        put :follow, params: { id: cookbook, list: true }

        expect(response).to render_template("cookbooks/_follow_button_list")
      end
    end

    context "the signed in user doesn't follow the specified cookbook" do
      before { sign_in create(:user) }

      it "should not remove a follower" do
        expect do
          delete :unfollow, params: { id: cookbook }
        end.to_not change(cookbook.cookbook_followers, :count)
      end

      it "returns a 404" do
        delete :unfollow, params: { id: cookbook }

        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe "PUT #deprecate" do
    let(:user) { create(:user) }
    let!(:cookbook) { create(:cookbook, owner: user) }
    let!(:other_cookbook) { create(:cookbook, owner: user) }
    let!(:replacement_cookbook) { create(:cookbook) }

    context "cookbook owner" do
      context "no replacement" do
        before do
          sign_in(user)
        end

        it "deprecates the cookbook and sets the replacement" do
          put(:deprecate, params: { id: cookbook, cookbook: {
                replacement: "",
              } })

          cookbook.reload

          expect(cookbook.deprecated).to eql(true)
          expect(cookbook.replacement).to eql(nil)
        end

        it "redirects back to the cookbook w/ success notice" do
          put(:deprecate, params: { id: cookbook, cookbook: {
                replacement: "",
              } })

          expect(response).to redirect_to(cookbook)

          expect(flash[:notice]).to eql(
            I18n.t(
              "cookbook.deprecated",
              cookbook: cookbook.name
            )
          )
        end

        it "starts the cookbook deprecated notifier worker" do
          expect do
            put(:deprecate, params: { id: cookbook, cookbook: {
                  replacement: "",
                } })
          end.to change(CookbookDeprecatedNotifier.jobs, :size).by(1)
        end
      end

      context "valid replacement" do
        before do
          sign_in(user)
        end

        it "deprecates the cookbook and sets the replacement" do
          put(:deprecate, params: { id: cookbook, cookbook: {
                replacement: replacement_cookbook.name,
              } })

          cookbook.reload

          expect(cookbook.deprecated).to eql(true)
          expect(cookbook.replacement).to eql(replacement_cookbook)
        end

        it "redirects back to the cookbook w/ success notice" do
          put(:deprecate, params: { id: cookbook, cookbook: {
                replacement: replacement_cookbook.name,
              } })

          expect(response).to redirect_to(cookbook)

          expect(flash[:notice]).to eql(
            I18n.t(
              "cookbook.deprecated",
              cookbook: cookbook.name
            )
          )
        end

        it "starts the cookbook deprecated notifier worker" do
          expect do
            put(:deprecate, params: { id: cookbook, cookbook: {
                  replacement: replacement_cookbook,
                } })
          end.to change(CookbookDeprecatedNotifier.jobs, :size).by(1)
        end
      end

      context "replacement cookbook already deprecated" do
        before { sign_in(user) }
        let!(:deprecated_cookbook) do
          create(:cookbook, deprecated: true, replacement: create(:cookbook))
        end

        it "fails to deprecate and set replacement" do
          put(:deprecate, params: { id: cookbook, cookbook: {
                replacement: deprecated_cookbook,
              } })

          cookbook.reload

          expect(cookbook.deprecated).to eql(false)
          expect(cookbook.replacement).to eql(nil)
        end

        it "redirects back to the cookbook w/ an error notice" do
          put(:deprecate, params: { id: cookbook, cookbook: {
                replacement: deprecated_cookbook,
              } })

          expect(response).to redirect_to(cookbook)
          expect(flash[:notice])
            .to eql(I18n.t("cookbook.deprecate_with_deprecated_failure"))
        end
      end
    end

    context "not the cookbook owner" do
      before { sign_in(create(:user)) }

      it "returns a 404" do
        put(:deprecate, params: { id: cookbook, cookbook: {
              replacement: replacement_cookbook,
            } })

        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe "DELETE #undeprecate" do
    let(:user) { create(:user) }
    let!(:cookbook) do
      create(:cookbook,
             owner: user,
             deprecated: true,
             replacement: create(:cookbook))
    end
    before { sign_in(user) }

    it "unsets a cookbook as deprecated" do
      delete :undeprecate, params: { id: cookbook }

      expect(cookbook.reload.deprecated).to be false
    end

    it "sets a cookbooks replacement to nil" do
      delete :undeprecate, params: { id: cookbook }

      expect(cookbook.reload.replacement).to be_nil
    end

    it "redirects back to the cookbook" do
      delete :undeprecate, params: { id: cookbook }

      expect(response).to redirect_to(cookbook)
    end

    it "404s if the user is not authorized to undeprecate the cookbook" do
      sign_in(create(:user))

      delete :undeprecate, params: { id: cookbook }

      expect(response.status.to_i).to eql(404)
    end
  end

  describe "PUT #toggle_featured" do
    let(:admin) { create(:admin) }
    let(:unfeatured) { create(:cookbook, featured: false) }
    let(:featured) { create(:cookbook, featured: true) }
    before { sign_in(admin) }

    it "sets a cookbook as featured if it is not already featured" do
      put :toggle_featured, params: { id: unfeatured }

      unfeatured.reload
      expect(unfeatured.featured).to eql(true)
    end

    it "sets a cookbook as not featured if it is already featured" do
      put :toggle_featured, params: { id: featured }

      featured.reload
      expect(featured.featured).to eql(false)
    end

    it "redirects back to the cookbook" do
      put :toggle_featured, params: { id: unfeatured }

      expect(response).to redirect_to(unfeatured)
    end

    it "404s if the user is not authorized to feature/unfeature a cookbook" do
      sign_in(create(:user))

      put :toggle_featured, params: { id: unfeatured }

      expect(response.status.to_i).to eql(404)
    end
  end

  describe "GET #deprecate_search" do
    let!(:postgresql) { create(:cookbook, name: "postgresql") }

    it "responds with a 200" do
      get :deprecate_search, params: { id: postgresql, q: "postgresql", format: :json }

      expect(response.status.to_i).to eql(200)
    end

    it "responds with JSON" do
      get :deprecate_search, params: { id: postgresql, q: "postgresql", format: :json }

      expect(response.content_type).to eql("application/json")
    end

    it "assigns results" do
      get :deprecate_search, params: { id: postgresql, q: "postgresql", format: :json }

      expect(assigns[:results]).to_not be_nil
    end

    it "defaults q to nil if not passed in" do
      get :deprecate_search, params: { id: postgresql, format: :json }

      expect(response.status.to_i).to eql(200)
    end
  end

  describe "GET #available_for_adoption" do
    let!(:adoptable_cookbook) { create(:cookbook, up_for_adoption: true) }
    let!(:unadoptable_cookbook) { create(:cookbook) }

    it "has instance variable" do
      get :available_for_adoption

      expect(assigns[:available_cookbooks]).to_not be_nil
    end

    it "finds adoptable cookbooks" do
      get :available_for_adoption

      expect(assigns[:available_cookbooks]).to include(adoptable_cookbook)
      expect(assigns[:available_cookbooks]).to_not include(unadoptable_cookbook)
    end
  end
end
