Bringit::Application.routes.draw do
  devise_for :users

  get "home/index"
  
  root to: 'home#index'
  
  post '/development/session' => 'sessions#create', as: :development_session
  
  resources :repositories do
    get :autocomplete_repository_title, :on => :collection
    post 'upload' => "repositories#upload"
  end
  
  match '/repositories/:id/:url' => "repositories#show", constraints: { url: /.*/ }, as: :browse_repository
  match '/raw/repositories/:id/:url' => "repositories#raw", constraints: { url: /.*/ }, as: :raw_repository
  post '/repositories/:id' => "repositories#update"
  delete '/delete_file/repositories/:id/:url' => "repositories#delete_file", constraints: { url: /.*/ }, as: :delete_file_repository
  post '/update_file/repositories/:id/:url' => "repositories#update_file", constraints: { url: /.*/ }, as: :update_file_repository
  
  match '/commits/:id/:oid/:url' => "repositories#show", constraints: { url: /.*/ }, as: :browse_commits
  
  match '/commits/:id' => "repositories#commits", as: :commits
  
  match '/search', to: 'repositories#search'
end
