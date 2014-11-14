class PlayerCostsController < ApplicationController
  before_action :set_player_cost, only: [:update]

  def update
    pcs = PlayerCost.where(player_id: @player_cost.player_id, game_id: @player_cost.game_id, site_id: @player_cost.site_id)
    pcs.each do |pc|
      pc.healthy = params[:healthy]
      pc.save
    end
    render json: {success: true}
  end

  private

    def set_player_cost
      @player_cost = PlayerCost.find(params[:id])
    end

end
