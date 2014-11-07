class AddActualPointsDkToPlayerCosts < ActiveRecord::Migration
  def change
    add_column :player_costs, :actual_points_dk, :float
  end
end
