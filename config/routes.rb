Supermarket::Application.routes.draw do
  scope 'api', module: 'api' do
    resources :icla_signatures, path: 'icla-signatures'
    resources :users
  end

  get 'login' => 'sessions#new'
  delete 'logout' => 'sessions#destroy'
  get 'auth/:provider/callback' => 'sessions#create', as: :auth_callback
  get 'auth/failure' => 'sessions#failure', as: :auth_failure

  root 'sessions#new'
end
