require 'spec_helper'

describe Curry::RepositoriesController do
  describe 'GET #index' do
    context 'when signed in as an admin' do
      before { sign_in(create(:admin)) }

      it 'lists the subscribed repositories' do
        get :index

        repositories = assigns(:repositories)

        expect(repositories).to_not be_nil
      end

      it 'provides a blank repository for the view' do
        get :index

        repository = assigns(:repository)

        expect(repository).to_not be_nil
      end
    end

    context 'when signed in as a non-admin' do
      it '404s' do
        sign_in create(:user)

        get :index

        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe 'POST #create' do
    context 'as an admin' do
      before { sign_in create(:admin) }

      context 'when the environment has no set PubSubHubbub callback url' do

        it 'subscribes using the PR update endpoint as the callback url' do
          callback = ENV['PUBSUBHUBBUB_CALLBACK_URL']
          ENV['PUBSUBHUBBUB_CALLBACK_URL'] = ''

          expect_any_instance_of(Curry::RepositorySubscriber).
            to receive(:subscribe).
            with(curry_pull_request_updates_url) { true }

          post :create, curry_repository: {
            owner: 'gofullstack',
            name: 'paprika'
          }

          ENV['PUBSUBHUBBUB_CALLBACK_URL'] = callback
        end
      end

      context 'when subscribing to a repository succeeds' do
        before do
          allow_any_instance_of(Curry::RepositorySubscriber).to receive(:subscribe) { true }
        end

        it 'redirects back to the repository index' do
          post :create, curry_repository: { owner: 'gofullstack', name: 'paprika' }

          expect(response).to redirect_to(curry_repositories_url)
        end

        it 'notifies the user that the repository was created' do
          post :create, curry_repository: { owner: 'rocky' }

          expect(flash[:notice]).
            to eql(I18n.t('curry.repositories.subscribe.success'))
        end
      end

      context 'when creating a repository fails' do
        before do
          allow_any_instance_of(Curry::RepositorySubscriber).to receive(:subscribe) { false }
          allow_any_instance_of(Curry::RepositorySubscriber).to receive(:repository)
        end

        it 'alerts the user that the repository was not saved' do
          post :create, curry_repository: { owner: 'rocky' }

          expect(flash.now[:alert]).
            to eql(I18n.t('curry.repositories.subscribe.failure'))
        end

        it 'renders the repository index' do
          post :create, curry_repository: { name: 'bullwinkle' }

          expect(response).to render_template('index')
        end

        it 'provides the view with all repositories' do
          post :create, curry_repository: { name: 'bullwinkle' }

          repositories = assigns(:repositories)

          expect(repositories).to_not be_nil
        end
      end
    end

    context 'as a non-admin' do
      it '404s' do
        sign_in create(:user)

        post :create, curry_repository: { owner: 'rocky' }

        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'redirects with a success message after unsubscribing' do
      sign_in create(:admin)

      repository = create(:repository)
      allow_any_instance_of(Curry::RepositorySubscriber).to receive(:unsubscribe) { true }

      delete :destroy, id: repository.id

      expect(flash[:notice]).
        to eql(I18n.t('curry.repositories.unsubscribe.success'))
      expect(response).to redirect_to(curry_repositories_url)
    end

    it 'redirects with a failure message if unsubscribing fails' do
      sign_in create(:admin)

      repository = create(:repository)
      allow_any_instance_of(Curry::RepositorySubscriber).to receive(:unsubscribe) { false }

      delete :destroy, id: repository.id

      expect(flash[:alert]).
        to eql(I18n.t('curry.repositories.unsubscribe.failure'))
      expect(response).to redirect_to(curry_repositories_url)
    end
  end
end
