class CreatePlayerCosts < ActiveRecord::Migration
  def change
    create_table :player_costs do |t|
      t.integer :player_id
      t.integer :game_id
      t.integer :site_id
      t.string :position
      t.string :alt_position
      t.integer :salary

      t.timestamps
    end
  end
end
