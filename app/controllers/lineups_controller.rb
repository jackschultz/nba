class LineupsController < ApplicationController

  before_action :set_site
  before_action :set_date, only: [:index]

  def index
    if params[:games].empty?
      @games = Game.on_date(@date)
    else
      gids = params[:games].map{|gid| gid.to_i}
      @games = Game.find(gids)
    end
    @player_costs = @site.player_costs.includes(:player).from_games(@games.map(&:id)).positive.primary.healthy
    if !params[:locks].nil?
      locked_ids = params[:locks].map{|lid| lid.to_i}
      @player_costs.each do |pc|
        if locked_ids.include?(pc.id) && pc.primary?
          pc.locked = true
        end
      end
    end
    site_id = params[:site_id].to_i
    @lineup = Lineups::Generate.generate_lineups(@player_costs, site_id)
    render json: [@lineup.first.to_json, @lineup.last.to_json]
  end

  private

  def set_date
    @date = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
  end

  def set_site
    @site = Site.find(params[:site_id])
  end

end
