Supermarket::Application.routes.draw do
  namespace :api do
    resources :icla_signatures, path: 'icla-signatures'
    resources :users
  end

  resources :icla_signatures, path: 'icla-signatures'

  get 'login'   => redirect('/sign-in'), as: nil
  get 'signin'  => redirect('/sign-in'), as: nil
  get 'sign-in' => 'sessions#new', as: :sign_in

  delete 'logout'   => redirect('/sign-out'), as: nil
  delete 'signout'  => redirect('/sign-out'), as: nil
  delete 'sign-out' => 'sessions#destroy', as: :sign_out

  match 'auth/:provider/callback' => 'sessions#create', as: :auth_callback, via: [:get, :post]
  get 'auth/failure' => 'sessions#failure', as: :auth_failure

  root 'icla_signatures#index'
end
