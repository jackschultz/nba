class AddStartingToPlayerCost < ActiveRecord::Migration
  def change
    add_column :player_costs, :starting, :boolean, default: false
  end
end
