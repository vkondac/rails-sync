Rails.application.routes.draw do
  # Authentication
  post '/login', to: 'auth#login'
  
  # WatermelonDB Sync
  get '/sync', to: 'sync#pull'
  post '/sync', to: 'sync#push'
  get '/sync/replacement', to: 'sync#replacement'
  
  # Regular CRUD for testing
  resources :cars
  
  # Health check
  get '/health', to: 'application#health'
end