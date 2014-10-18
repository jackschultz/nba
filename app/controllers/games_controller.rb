class GamesController < ApplicationController

  before_action :set_date, only: [:show]

  def index
    @games = Game.all
  end

  def show
    @games = Game.where(date: @date..@date+1.day)
  end

  private

    def set_date
      @date = Date.new(params[:year],params[:month],params[:day])
    end

end
