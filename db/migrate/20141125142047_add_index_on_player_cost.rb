class AddIndexOnPlayerCost < ActiveRecord::Migration
  def change
    add_index :player_costs, [:site_id, :game_id, :player_id]
  end
end
