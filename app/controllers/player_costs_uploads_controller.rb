class PlayerCostsUploadsController < ApplicationController

  before_action :set_site
  before_action :set_date, only: [:create]

  def create
    @games = Game.on_date(@date)
    #we want to grab all the players costs for the user if they've already uploaded,
    #otherwise, just the pcs with no user
    if current_user && @site.player_costs.from_games(@games.map(&:id)).where(user_id: current_user.id).count > 0
      @player_costs = @site.player_costs.for_user(current_user.id).from_games(@games.map(&:id))
      #update the pcs for this user
    else
      @player_costs = @site.player_costs.no_user.from_games(@games.map(&:id))
      #create new pcs for this user
      @player_costs.each do |pc|
        user_pc = pc.dup
        user_pc.user_id = current_user.id
      end
    end


  end

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
    @games = Game.on_date(@date)
    if current_user && @site.player_costs.from_games(@games.map(&:id)).where(user_id: current_user.id).count > 0
      @player_costs = @site.player_costs.includes(:player).where(user_id: current_user.id).from_games(@games.map(&:id))
    else
      @player_costs = @site.player_costs.includes(:player).from_games(@games.map(&:id))
    end

    render json: @player_costs, include: :player
  end

  private

  def set_date
    @date = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
  end

  def set_site
    @site = Site.find(params[:site_id])
  end

end
