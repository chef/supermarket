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
    end
  end

  get 'cookbooks-directory' => 'cookbooks#directory'
  get 'universe' => 'api/v1/universe#index', defaults: { format: :json }

  resources :cookbooks, only: [:index, :show, :update] do
    resources :collaborators, only: [:index, :new, :create, :destroy] do
      member do
        put :transfer
      end
    end

    member do
      get :download
      put :follow
      delete :unfollow
      put :transfer_ownership
      put :deprecate
    end

    get 'versions/:version/download' => 'cookbook_versions#download', as: :version_download, constraints: { version: VERSION_PATTERN }
    get 'versions/:version' => 'cookbook_versions#show', as: :version, constraints: { version: VERSION_PATTERN }
  end

  resources :icla_signatures, path: 'icla-signatures' do
    collection do
      post :re_sign, path: 're-sign'
      get :agreement
    end
  end

  resources :ccla_signatures, path: 'ccla-signatures' do
    collection do
      post :re_sign, path: 're-sign'
      get :agreement
    end

    member do
      get :contributors
    end

    resources :contributor_requests, only: [:create], constraints: proc { ENV['JOIN_CCLA_ENABLED'] } do
      member do
        get :accept
        get :decline
      end
    end
  end

  namespace :curry do
    resources :repositories, only: [:index, :create, :destroy] do
      member do
        post :evaluate
      end
    end

    resources :pull_request_updates, only: [:create]
  end

  resources :users, only: [:show] do
    member do
      if ENV['TOOLS_ENABLED'] == 'true'
        get :tools
      end

      put :make_admin
      delete :revoke_admin
    end

    resources :accounts, only: [:destroy]
  end

  if ENV['TOOLS_ENABLED'] == 'true'
    resources :tools
  end

  resource :profile, controller: 'profile', only: [:update, :edit] do
    collection do
      patch :change_password
      get :link_github, path: 'link-github'
    end
  end

  resources :invitations, only: [:show] do
    member do
      get :accept
      get :decline
    end
  end

  resources :organizations, only: [:show, :destroy] do
    member do
      put :combine

      if ENV['JOIN_CCLA_ENABLED'] == 'true'
        get :requests_to_join
      end
    end

    resources :contributors, only: [:update, :destroy], controller: :contributors

    resources :invitations, only: [:index, :create, :update],
                            controller: :organization_invitations do

      member do
        patch :resend
        delete :revoke
      end
    end
  end

  get 'become-a-contributor' => 'contributors#become_a_contributor'
  get 'contributors' => 'contributors#index'

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
