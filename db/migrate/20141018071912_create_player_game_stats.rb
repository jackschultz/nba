class CreatePlayerGameStats < ActiveRecord::Migration
  def change
    create_table :player_game_stats do |t|
      t.integer :player_id
      t.integer :game_id
      t.integer :minutes
      t.integer :fga
      t.integer :fgm
      t.float :fg_pct
      t.integer :fg3m
      t.integer :fg3a
      t.float :fg3_pct
      t.integer :ftm
      t.integer :fga
      t.integer :ft_pct
      t.integer :oreb
      t.integer :dreb
      t.integer :rebounds
      t.integer :assists
      t.integer :turnovers
      t.integer :steals
      t.integer :blocks
      t.integer :fouls
      t.integer :points
      t.integer :plus_minus

      t.timestamps
    end
  end
end
