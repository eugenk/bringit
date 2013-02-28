Bringit::Application.routes.draw do
  devise_for :users

  get "home/index"
  
  root to: 'home#index'
  
  post '/development/session' => 'sessions#create', as: :development_session
  
  resources :repositories do
    get :autocomplete_repository_title, :on => :collection
    post 'upload' => "repositories#upload"
  end
  
  get '/repositories/:id/:url' => "repositories#show", constraints: { url: /.*/ }, as: :browse_repository
  
  get '/raw/repositories/:id/:url' => "repositories#raw", constraints: { url: /.*/ }, as: :raw_repository
  get '/raw/commits/:id/:oid/:url' => "repositories#raw", constraints: { url: /.*/ }, as: :raw_commits
  
  post '/repositories/:id' => "repositories#update"
  delete '/delete_file/repositories/:id/:url' => "repositories#delete_file", constraints: { url: /.*/ }, as: :delete_file_repository
  post '/update_file/repositories/:id/:url' => "repositories#update_file", constraints: { url: /.*/ }, as: :update_file_repository
  
  get '/commits/:id/:oid' => "repositories#show", as: :browse_commits_root
  get '/commits/:id/:oid/:url' => "repositories#show", constraints: { url: /.*/ }, as: :browse_commits
  
  get '/commits/:id' => "repositories#commits", as: :commits
  get '/entries/:id' => "repositories#entries_info", as: :entries
  
  get '/history/repositories/:id/:url' => "repositories#history", constraints: { url: /.*/ }, as: :history_repository
  get '/history/commits/:id/:oid/:url' => "repositories#history", constraints: { url: /.*/ }, as: :history_commits
  
  get '/search', to: 'repositories#search'
end
