require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  mount Leather::Engine => '/'
  mount Sidekiq::Web, at: '/sidekiq'

  resources :teams, only: [:index, :show, :edit, :update]
  resources :players

  resources :games, only: [:index, :show]
  get '/games/:year/:month/:day' => 'games#date', as: :games_date, constraints: {
    year:       /\d{4}/,
    month:      /\d{1,2}/,
    day:        /\d{1,2}/
  }

  resources :lineups, only: [:index]

  resources :player_costs, only: [:update, :index]

  resources :stats, only: [:index]

  resources :sites, only: [:index, :show]

end
