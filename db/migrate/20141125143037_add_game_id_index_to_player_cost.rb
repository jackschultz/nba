class AddGameIdIndexToPlayerCost < ActiveRecord::Migration
  def change
    add_index :player_costs, [:game_id]
  end
end
