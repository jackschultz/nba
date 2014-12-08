class PlayerCostsController < ApplicationController

  before_action :set_site
  before_action :set_player_cost, only: [:update]
  before_action :set_date, only: [:index]

  def update
    pcs = @site.player_costs.where(player_id: @player_cost.player_id, game_id: @player_cost.game_id, site_id: @player_cost.site_id)
    pcs.each do |pc|
      pc.locked = params[:locked] if !params[:locked].nil? && pc.primary?
      pc.healthy = params[:healthy] if !params[:healthy].nil?
      if !pc.healthy?
        pc.locked = false
      end
      pc.save
    end
    pc = pcs.primary
    render json: pc, include: :player
  end

  def index
    @games = Game.on_date(@date)#Game.where(date: @date..@date+1.day-1.hour)
    @player_costs = @site.player_costs.primary.from_games(@games.map(&:id))
    render json: @player_costs, include: :player
  end

  private

    def set_player_cost
      @player_cost = PlayerCost.find(params[:id])
    end

  def set_date
    @date = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
  end

  def set_site
    @site = Site.find(params[:site_id])
  end

end
