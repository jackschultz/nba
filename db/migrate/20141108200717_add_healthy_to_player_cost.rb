class AddHealthyToPlayerCost < ActiveRecord::Migration
  def change
    add_column :player_costs, :healthy, :boolean, default: true
  end
end
