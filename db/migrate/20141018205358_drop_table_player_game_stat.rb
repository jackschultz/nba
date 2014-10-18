class DropTablePlayerGameStat < ActiveRecord::Migration
  def change
    drop_table :player_game_stats
  end
end
