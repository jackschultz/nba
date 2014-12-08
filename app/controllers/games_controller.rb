class GamesController < ApplicationController

  before_action :set_site, only: [:date]
  before_action :set_game, only: [:show]

  def index
    @games = Game.all
  end

  def date
    @date = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
    @games = Game.on_date(@date)#Game.where(date: @date..@date+1.day-1.hour)
  end

  def show
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def set_site
    @site = Site.find(params[:site_id])
  end

end
