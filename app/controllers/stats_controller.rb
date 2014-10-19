class StatsController < ApplicationController

  def index
    lebron = Player.find(48)
    data = lebron.minutes
    render json: data
  end

  private

  def load_player
    @player = Player.find(params[:id])
  end

end
