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
  
  
  match '/search', to: 'repositories#search'
end
