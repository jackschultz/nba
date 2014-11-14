class GamesController < ApplicationController

  before_action :set_date, only: [:date]
  before_action :set_game, only: [:show]

  def index
    @games = Game.all
  end

  def date
    @games = Game.on_date(@date)#Game.where(date: @date..@date+1.day-1.hour)
    @player_costs = []
    @player_costs = PlayerCost.primary.from_games(@games.map(&:id))
    @player_costs.to_a.sort! { |a, b|  a.expected_points <=> b.expected_points }.reverse!
  end

  def show
  end

  private

  def set_date
    @date = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
  end

  def set_game
    @game = Game.find(params[:id])
  end

end
