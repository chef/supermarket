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

  namespace :api do
    resources :icla_signatures, path: 'icla-signatures'
    resources :users
  end

  resources :icla_signatures, path: 'icla-signatures'
  resources :ccla_signatures, path: 'ccla-signatures'
  resources :users, only: [:show] do
    resources :accounts, only: [:destroy]
  end

  resource :profile, controller: 'profile', only: [:update, :edit]

  resources :invitations, only: [:show, :update, :destroy]

  resources :organizations, only: [] do
    resources :contributors, only: [:update, :destroy], controller: :contributors

    resources :invitations,
      only: [:index, :create],
      controller: :organization_invitations
  end

  match 'auth/:provider/callback' => 'accounts#create', as: :auth_callback, via: [:get, :post]
  get 'auth/failure' => 'sessions#failure', as: :auth_failure

  root 'icla_signatures#index'
end
