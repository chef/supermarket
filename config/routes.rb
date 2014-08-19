Supermarket::Application.routes.draw do
  VERSION_PATTERN = /latest|([0-9_\-\.]+)/ unless defined?(VERSION_PATTERN)

  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  namespace :api, defaults: { format: :json }  do
    namespace :v1 do
      get 'metrics' => 'metrics#show'
      get 'health' => 'health#show'
      get 'cookbooks' => 'cookbooks#index'
      get 'search' => 'cookbooks#search'
      get 'cookbooks/:cookbook' => 'cookbooks#show', as: :cookbook
      get 'cookbooks/:cookbook/versions/:version' => 'cookbook_versions#show', as: :cookbook_version, constraints: { version: VERSION_PATTERN }
      get 'cookbooks/:cookbook/versions/:version/download' => 'cookbook_versions#download', as: :cookbook_version_download, constraints: { version: VERSION_PATTERN }
      post 'cookbooks' => 'cookbook_uploads#create'
      delete 'cookbooks/:cookbook' => 'cookbook_uploads#destroy'
      get 'users/:user' => 'users#show', as: :user
      post '/cookbook-verisons/evaluation' => 'cookbook_versions#evaluation', as: :cookbook_versions_evaluation, constraints: proc { ROLLOUT.active?(:fieri) }

      get 'tools/:tool' => 'tools#show', as: :tool
      get 'tools' => 'tools#index', as: :tools
    end
  end

  get 'cookbooks-directory' => 'cookbooks#directory'
  get 'universe' => 'api/v1/universe#index', defaults: { format: :json }
  get 'status' => 'api/v1/health#show', defaults: { format: :json }

  resources :cookbooks, only: [:index, :show, :update] do
    member do
      get :download
      put :follow
      delete :unfollow
      put :transfer_ownership
      put :deprecate
      delete :deprecate, action: 'undeprecate'
      put :toggle_featured
      get :deprecate_search
    end

    get 'versions/:version/download' => 'cookbook_versions#download', as: :version_download, constraints: { version: VERSION_PATTERN }
    get 'versions/:version' => 'cookbook_versions#show', as: :version, constraints: { version: VERSION_PATTERN }
  end

  resources :icla_signatures, path: 'icla-signatures', constraints: proc { ROLLOUT.active?(:cla) } do
    collection do
      post :re_sign, path: 're-sign'
      get :agreement
    end
  end

  resources :collaborators, only: [:index, :new, :create, :destroy] do
    member do
      put :transfer
    end
  end

  resources :ccla_signatures, path: 'ccla-signatures', constraints: proc { ROLLOUT.active?(:cla) } do
    collection do
      post :re_sign, path: 're-sign'
      get :agreement
    end

    member do
      get :contributors
    end

    resources :contributor_requests, only: [:create], constraints: proc { ROLLOUT.active?(:join_ccla) } do
      member do
        get :accept
        get :decline
      end
    end
  end

  namespace :curry, constraints: proc { ROLLOUT.active?(:cla) } do
    resources :repositories, only: [:index, :create, :destroy] do
      member do
        post :evaluate
      end
    end

    resources :pull_request_updates, only: [:create]
  end

  resources :users, only: [:show] do
    member do
      get :tools, constraints: proc { ROLLOUT.active?(:tools) }

      put :make_admin
      delete :revoke_admin
      get :followed_cookbook_activity, format: :atom
    end

    resources :accounts, only: [:destroy]
  end

  resources :tools, constraints: proc { ROLLOUT.active?(:tools) }

  resource :profile, controller: 'profile', only: [:update, :edit] do
    post :update_install_preference, format: :json

    collection do
      patch :change_password
      get :link_github, path: 'link-github'
    end
  end

  resources :invitations, constraints: proc { ROLLOUT.active?(:cla) }, only: [:show] do
    member do
      get :accept
      get :decline
    end
  end

  resources :organizations, constraints: proc { ROLLOUT.active?(:cla) }, only: [:show, :destroy] do
    member do
      put :combine

      get :requests_to_join, constraints: proc { ROLLOUT.active?(:join_ccla) }
    end

    resources :contributors, only: [:update, :destroy], controller: :contributors, constraints: proc { ROLLOUT.active?(:cla) }

    resources :invitations, only: [:index, :create, :update], constraints: proc { ROLLOUT.active?(:cla) },
                            controller: :organization_invitations do

      member do
        patch :resend
        delete :revoke
      end
    end
  end

  get 'become-a-contributor' => 'contributors#become_a_contributor', constraints: proc { ROLLOUT.active?(:cla) }
  get 'contributors' => 'contributors#index', constraints: proc { ROLLOUT.active?(:cla) }

  get 'chat' => 'irc_logs#index'
  get 'chat/:channel' => 'irc_logs#show'
  get 'chat/:channel/:date' => 'irc_logs#show'

  # when signing in or up with chef account
  match 'auth/chef_oauth2/callback' => 'sessions#create', as: :auth_session_callback, via: [:get, :post]
  get 'auth/failure' => 'sessions#failure', as: :auth_failure
  get 'login'   => redirect('/sign-in'), as: nil
  get 'signin'  => redirect('/sign-in'), as: nil
  get 'sign-in' => 'sessions#new', as: :sign_in
  get 'sign-up' => 'sessions#new', as: :sign_up

  delete 'logout'   => redirect('/sign-out'), as: nil
  delete 'signout'  => redirect('/sign-out'), as: nil
  delete 'sign-out' => 'sessions#destroy', as: :sign_out

  # when linking an oauth account
  match 'auth/:provider/callback' => 'accounts#create', as: :auth_callback, via: [:get, :post]

  # this is what a logged in user sees after login
  get 'dashboard' => 'pages#dashboard'

  root 'pages#welcome'
end
