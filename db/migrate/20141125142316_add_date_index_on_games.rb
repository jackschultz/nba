class AddDateIndexOnGames < ActiveRecord::Migration
  def change
    add_index :games, [:date]
  end
end
