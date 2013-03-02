Bringit::Application.routes.draw do
  devise_for :users

  get "home/index"
  
  root to: 'home#index'
  
  post '/development/session' => 'sessions#create', as: :development_session

  get '/autocomplete' => "repositories#autocomplete_repository_title", as: :autocomplete_repository_title_repositories
  get '/repositories' => "repositories#index", as: :repositories
  get '/new' => "repositories#new", as: :new_repository 
  post '/create' => "repositories#create", as: :repositories
  
  get '/repositories/:id/:url' => "repositories#show", constraints: { url: /.*/ }, as: :browse_repository
  
  get '/raw/repositories/:id/:url' => "repositories#raw", constraints: { url: /.*/ }, as: :raw_repository
  get '/raw/commits/:id/:oid/:url' => "repositories#raw", constraints: { url: /.*/ }, as: :raw_commits
  
  get '/repositories/:id' => "repositories#show", as: :repository
  
  post '/upload/:id' => "repositories#upload", as: :repository_upload
  
  delete '/delete/:id' => "repositories#destroy", as: :delete_repository
  
  match '/update/:id' => "repositories#update", as: :update_repository
  
  post '/repositories/:id' => "repositories#update", as: :repository
  delete '/delete_file/repositories/:id/:url' => "repositories#delete_file", constraints: { url: /.*/ }, as: :delete_file_repository
  post '/update_file/repositories/:id/:url' => "repositories#update_file", constraints: { url: /.*/ }, as: :update_file_repository
  
  get '/commits/:id/:oid' => "repositories#show", as: :browse_commits_root
  get '/commits/:id/:oid/:url' => "repositories#show", constraints: { url: /.*/ }, as: :browse_commits
  
  get '/commits/:id' => "repositories#commits", as: :commits
  get '/entries/:id' => "repositories#entries_info", as: :entries
  
  get '/history/repositories/:id/:url' => "repositories#history", constraints: { url: /.*/ }, as: :history_repository
  get '/history/commits/:id/:oid/:url' => "repositories#history", constraints: { url: /.*/ }, as: :history_commits
  
  get '/diff/:id' => "repositories#diff", as: :browse_diff_head
  get '/diff/:id/:oid' => "repositories#diff", as: :browse_diff
  
  get '/search', to: 'repositories#search'
end
