class PlayerCostsController < ApplicationController
  before_action :set_player_cost, only: [:update]

  def update
    @player_cost.healthy = params[:healthy]
    @player_cost.save
    render json: {success: true}
  end

  private

    def set_player_cost
      @player_cost = PlayerCost.find(params[:id])
    end

end
