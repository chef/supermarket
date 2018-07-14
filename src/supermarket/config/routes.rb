Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  VERSION_PATTERN = /latest|([0-9_\-\.]+)/ unless defined?(VERSION_PATTERN)

  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  mount Fieri::Engine, at: '/fieri', constraints: proc { Feature.active?(:fieri) }

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'metrics' => 'metrics#show'
      get 'health' => 'health#show'
      get 'cookbooks' => 'cookbooks#index'
      get 'search' => 'cookbooks#search'
      get 'cookbooks/:cookbook' => 'cookbooks#show', as: :cookbook
      get 'cookbooks/:cookbook/contingent' => 'cookbooks#contingent'
      get 'cookbooks/:cookbook/versions/:version' => 'cookbook_versions#show', as: :cookbook_version, constraints: { version: VERSION_PATTERN }
      get 'cookbooks/:cookbook/versions/:version/download' => 'cookbook_versions#download', as: :cookbook_version_download, constraints: { version: VERSION_PATTERN }
      post 'cookbooks' => 'cookbook_uploads#create'
      delete 'cookbooks/:cookbook' => 'cookbook_uploads#destroy'
      delete 'cookbooks/:cookbook/versions/:version' => 'cookbook_uploads#destroy_version', constraints: { version: VERSION_PATTERN }
      get 'users/:user' => 'users#show', as: :user

      # This was the original route, which has a misspelling (cookbook-verisons rather than cookbook-versions).  Keeping this here so as not to break anyone who is still depending on the original route.
      post '/cookbook-verisons/foodcritic_evaluation' => 'quality_metrics#foodcritic_evaluation', constraints: proc { Feature.active?(:fieri) }

      # This route has the correct spelling of cookbook-versions
      post '/cookbook-versions/foodcritic_evaluation' => 'quality_metrics#foodcritic_evaluation', as: :cookbook_versions_foodcritic_evaluation, constraints: proc { Feature.active?(:fieri) }
      post '/cookbook-versions/collaborators_evaluation' => 'quality_metrics#collaborators_evaluation', as: :cookbook_versions_collaborators_evaluation, constraints: proc { Feature.active?(:fieri) }
      post '/cookbook-versions/publish_evaluation' => 'quality_metrics#publish_evaluation', as: :cookbook_versions_publish_evaluation, constraints: proc { Feature.active?(:fieri) }
      post '/cookbook-versions/license_evaluation' => 'quality_metrics#license_evaluation', as: :cookbook_versions_license_evaluation, constraints: proc { Feature.active?(:fieri) }

      post '/quality_metrics/foodcritic_evaluation' => 'quality_metrics#foodcritic_evaluation', as: :quality_metrics_foodcritic_evaluation, constraints: proc { Feature.active?(:fieri) }
      post '/quality_metrics/collaborators_evaluation' => 'quality_metrics#collaborators_evaluation', as: :quality_metrics_collaborators_evaluation, constraints: proc { Feature.active?(:fieri) }
      post '/quality_metrics/publish_evaluation' => 'quality_metrics#publish_evaluation', as: :quality_metrics_publish_evaluation, constraints: proc { Feature.active?(:fieri) }
      post '/quality_metrics/license_evaluation' => 'quality_metrics#license_evaluation', as: :quality_metrics_license_evaluation, constraints: proc { Feature.active?(:fieri) }
      post '/quality_metrics/supported_platforms_evaluation' => 'quality_metrics#supported_platforms_evaluation', as: :quality_metrics_supported_platforms_evaluation, constraints: proc { Feature.active?(:fieri) }
      post '/quality_metrics/contributing_file_evaluation' => 'quality_metrics#contributing_file_evaluation', as: :quality_metrics_contributing_file_evaluation, constraints: proc { Feature.active?(:fieri) }
      post '/quality_metrics/testing_file_evaluation' => 'quality_metrics#testing_file_evaluation', as: :quality_metrics_testing_file_evaluation, constraints: proc { Feature.active?(:fieri) }
      post '/quality_metrics/version_tag_evaluation' => 'quality_metrics#version_tag_evaluation', as: :quality_metrics_version_tag_evaluation, constraints: proc { Feature.active?(:fieri) }
      post '/quality_metrics/no_binaries_evaluation' => 'quality_metrics#no_binaries_evaluation', as: :quality_metrics_no_binaries_evaluation, constraints: proc { Feature.active?(:fieri) }

      get 'tools/:tool' => 'tools#show', as: :tool
      get 'tools' => 'tools#index', as: :tools
      get 'tools-search' => 'tools#search', as: :tools_search
    end
  end

  get 'cookbooks-directory' => 'cookbooks#directory'
  get 'available_for_adoption' => 'cookbooks#available_for_adoption'
  get 'universe' => 'api/v1/universe#index', defaults: { format: :json }
  get 'status' => 'api/v1/health#show', defaults: { format: :json }
  get 'unsubscribe/:token' => 'email_preferences#unsubscribe', as: :unsubscribe

  put 'cookbooks/:id/transfer_ownership' => 'transfer_ownership#transfer', as: :transfer_ownership
  get 'ownership_transfer/:token/accept' => 'transfer_ownership#accept', as: :accept_transfer
  get 'ownership_transfer/:token/decline' => 'transfer_ownership#decline', as: :decline_transfer
  get 'cookbooks/versions' => 'cookbook_versions#index', as: :cookbook_releases, defaults: { format: :atom }

  resources :cookbooks, only: [:index, :show, :update] do
    member do
      get :download
      put :follow
      delete :unfollow
      put :deprecate
      delete :deprecate, action: 'undeprecate'
      put :toggle_featured
      get :deprecate_search
      post :adoption
    end

    get 'versions/:version/download' => 'cookbook_versions#download', as: :version_download, constraints: { version: VERSION_PATTERN }
    get 'versions/:version' => 'cookbook_versions#show', as: :version, constraints: { version: VERSION_PATTERN }
  end

  resources :collaborators, only: [:index, :new, :create, :destroy] do
    member do
      put :transfer
      delete :destroy_group
    end
  end

  post 'curry/pull_request_updates', to: proc { [410, {}, ['Curry/CLA feature has been removed.']] }

  resources :users, only: [:show] do
    member do
      get :tools, constraints: proc { Feature.active?(:tools) }
      get :groups

      put :make_admin
      delete :revoke_admin
      get :followed_cookbook_activity, format: :atom
    end

    resources :accounts, only: [:destroy]
  end

  resources :groups

  resources :group_members do
    member do
      post :make_admin
    end
  end

  resources :tools, constraints: proc { Feature.active?(:tools) } do
    member do
      post :adoption
    end
  end
  get 'tools-directory' => 'tools#directory', constraints: proc { Feature.active?(:tools) }

  resource :profile, controller: 'profile', only: [:update, :edit] do
    post :update_install_preference, format: :json

    collection do
      patch :change_password
      get :link_github, path: 'link-github'
    end
  end

  get 'chat' => 'irc_logs#index'
  get 'chat/:channel' => 'irc_logs#show'
  get 'chat/:channel/:date' => 'irc_logs#show'

  # when signing in or up with chef account
  match 'auth/chef_oauth2/callback' => 'sessions#create', as: :auth_session_callback, via: [:get, :post]
  get 'auth/failure' => 'sessions#failure', as: :auth_failure
  get 'login'   => redirect('/sign-in', status: 302), as: nil
  get 'signin'  => redirect('/sign-in', status: 302), as: nil
  get 'sign-in' => 'sessions#new', as: :sign_in
  get 'sign-up' => 'sessions#new', as: :sign_up

  delete 'logout'   => redirect('/sign-out', status: 302), as: nil
  delete 'signout'  => redirect('/sign-out', status: 302), as: nil
  delete 'sign-out' => 'sessions#destroy', as: :sign_out

  # when linking an oauth account
  match 'auth/:provider/callback' => 'accounts#create', as: :auth_callback, via: [:get, :post]

  # this is what a logged in user sees after login
  get 'dashboard' => 'pages#dashboard'
  get 'documentation' => 'pages#documentation', as: 'documentation'
  get 'robots.:format' => 'pages#robots'
  root 'pages#welcome'
end
