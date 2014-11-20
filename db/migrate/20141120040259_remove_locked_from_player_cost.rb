class RemoveLockedFromPlayerCost < ActiveRecord::Migration
  def change
    remove_column :player_costs, :locked
  end
end
