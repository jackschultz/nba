class GamesController < ApplicationController

  before_action :set_date, only: [:date]
  before_action :set_game, only: [:show]

  def index
    @games = Game.all
  end

  def date
    @games = Game.where(date: @date..@date+1.day)
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
