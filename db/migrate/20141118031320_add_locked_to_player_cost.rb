class AddLockedToPlayerCost < ActiveRecord::Migration
  def change
    add_column :player_costs, :locked, :boolean, default: false
  end
end
