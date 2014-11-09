class LineupsController < ApplicationController
  before_action :set_date, only: [:index]

  def index
    @games = Game.on_date(@date)
    @player_costs = []
    @player_costs = PlayerCost.from_games(@games.map(&:id)).where(healthy: true)
    @lineup = Lineups::Generate.generate_lineups(@player_costs)
    render json: @lineup.to_json
  end

  private

  def set_date
    @date = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
  end

end
