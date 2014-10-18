require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  mount Leather::Engine => '/'
  mount Sidekiq::Web, at: '/sidekiq'

  resources :teams
  resources :players

  resources :games, only: [:index]
  get '/games/:year/:month/:day' => 'games#show', constraints: {
    year:       /\d{4}/,
    month:      /\d{1,2}/,
    day:        /\d{1,2}/
  }

end
