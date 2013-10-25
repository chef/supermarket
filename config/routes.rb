Supermarket::Application.routes.draw do
  scope 'api', module: 'api' do
    resources :icla_signatures, path: 'icla-signatures'
    resources :users
  end

  get 'auth/:provider/callback', to: 'sessions#create'
end
