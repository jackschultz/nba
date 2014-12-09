class CreateUserPlayerCosts < ActiveRecord::Migration
  def change
    create_table :user_player_costs do |t|
      t.integer :player_cost_id
      t.integer :user_id
      t.float :expected_points

      t.timestamps
    end
  end
end
