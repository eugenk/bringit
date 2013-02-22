Bringit::Application.routes.draw do
  devise_for :users

  get "home/index"
  
  root to: 'home#index'
  
  post '/development/session' => 'sessions#create', as: :development_session
  
  resources :repositories do
    get :autocomplete_repository_title, :on => :collection
  end
  
  match '/search', to: 'repositories#search'
end
