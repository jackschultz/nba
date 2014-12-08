require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  mount Sidekiq::Web, at: '/sidekiq'

  root 'homes#index'

  resources :teams, only: [:index, :show, :edit, :update]
  resources :players

  resources :sites, only: [:index, :show]  do
    get '/games/:year/:month/:day' => 'games#date', as: :games_date, constraints: {
      year:       /\d{4}/,
      month:      /\d{1,2}/,
      day:        /\d{1,2}/
    }

    resources :player_costs, only: [:update, :index]

    resources :lineups, only: [:index]

  end

  resources :games, only: [:index, :show]

  resources :stats, only: [:index]

end
