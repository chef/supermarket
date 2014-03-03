Supermarket::Application.routes.draw do
  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  devise_for :users

  devise_scope :user do
     get 'sign-in',  to: 'devise/sessions#new', as: :sign_in
     delete 'sign-out', to: 'devise/sessions#destroy', as: :sign_out
     get 'sign-up',  to: 'devise/registrations#new', as: 'sign_up'
   end

  namespace :api, defaults: { format: :json }  do
    namespace :v1 do
      get 'cookbooks' => 'cookbooks#index'
      get 'cookbooks/:cookbook' => 'cookbooks#show', as: :cookbook
      get 'cookbooks/:cookbook/versions/:version' => 'cookbook_versions#show', as: :cookbook_version
    end
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

    resources :invitations,
      only: [:index, :create, :update],
      controller: :organization_invitations do

      member do
        patch :resend
        delete :revoke
      end
    end
  end

  match 'auth/:provider/callback' => 'accounts#create', as: :auth_callback, via: [:get, :post]
  get 'auth/failure' => 'sessions#failure', as: :auth_failure

  root 'icla_signatures#index'
end
