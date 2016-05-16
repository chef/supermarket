Fieri::Engine.routes.draw do
  post 'jobs', to: 'jobs#create'
end
