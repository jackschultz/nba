class RemoveAltPositionFromPlayerCosts < ActiveRecord::Migration
  def change
    remove_column :player_costs, :alt_position, :string
  end
end
