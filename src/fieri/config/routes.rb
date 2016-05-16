Fieri::Engine.routes.draw do
  post 'jobs', to: 'jobs#create'
  get 'status', to: 'status#show'
end
