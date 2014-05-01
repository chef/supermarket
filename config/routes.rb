Supermarket::Application.routes.draw do
  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  namespace :api, defaults: { format: :json }  do
    namespace :v1 do
      get 'cookbooks' => 'cookbooks#index'
      get 'search' => 'cookbooks#search'
      get 'cookbooks/:cookbook' => 'cookbooks#show', as: :cookbook
      get 'cookbooks/:cookbook/versions/:version' => 'cookbook_versions#show', as: :cookbook_version
      post 'cookbooks' => 'cookbook_uploads#create'
      delete 'cookbooks/:cookbook' => 'cookbook_uploads#destroy'
    end
  end

  get 'cookbooks/directory' => 'cookbooks#directory'
  get 'cookbooks(/categories/:category)' => 'cookbooks#index', as: :cookbooks_category
  get 'cookbooks/categories', to: redirect('/cookbooks')

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
    end

    get 'versions/:version/download' => 'cookbook_versions#download', as: :version_download
    get 'versions/:version' => 'cookbook_versions#show', as: :version
  end

  resources :icla_signatures, path: 'icla-signatures' do
    collection do
      post :re_sign, path: 're-sign'
    end
  end

  resources :ccla_signatures, path: 'ccla-signatures' do
    collection do
      post :re_sign, path: 're-sign'
    end
  end

  namespace :curry do
    resources :repositories, only: [:index, :create, :destroy]
    resources :pull_request_updates, only: [:create]
  end

  resources :users, only: [:show] do
    resources :accounts, only: [:destroy]
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

  resources :organizations, only: [] do
    resources :contributors, only: [:update, :destroy], controller: :contributors

    resources :invitations, only: [:index, :create, :update],
                            controller: :organization_invitations do

      member do
        patch :resend
        delete :revoke
      end
    end
  end

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

  # when linking a github account
  match 'auth/github/callback' => 'accounts#create', as: :auth_callback, via: [:get, :post]

  # this is what a logged in user sees after login
  get 'dashboard' => 'pages#dashboard'

  root 'pages#welcome'
end
