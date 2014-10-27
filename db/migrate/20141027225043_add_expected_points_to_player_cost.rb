class AddExpectedPointsToPlayerCost < ActiveRecord::Migration
  def change
    add_column :player_costs, :expected_points, :float
  end
end
