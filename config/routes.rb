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
  match '/raw/commits/:id/:oid/:url' => "repositories#raw", constraints: { url: /.*/ }, as: :raw_commits
  
  post '/repositories/:id' => "repositories#update"
  delete '/delete_file/repositories/:id/:url' => "repositories#delete_file", constraints: { url: /.*/ }, as: :delete_file_repository
  post '/update_file/repositories/:id/:url' => "repositories#update_file", constraints: { url: /.*/ }, as: :update_file_repository
  
  match '/commits/:id/:oid' => "repositories#show", as: :browse_commits_root
  match '/commits/:id/:oid/:url' => "repositories#show", constraints: { url: /.*/ }, as: :browse_commits
  
  match '/commits/:id' => "repositories#commits", as: :commits
  match '/entries/:id' => "repositories#entries_info", as: :entries
  
  match '/history/repositories/:id/:url' => "repositories#history", constraints: { url: /.*/ }, as: :history_repository
  match '/history/commits/:id/:oid/:url' => "repositories#history", constraints: { url: /.*/ }, as: :history_commits
  
  match '/search', to: 'repositories#search'
end
