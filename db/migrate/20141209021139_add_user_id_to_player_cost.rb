class AddUserIdToPlayerCost < ActiveRecord::Migration
  def change
    add_column :player_costs, :user_id, :integer
  end
end
