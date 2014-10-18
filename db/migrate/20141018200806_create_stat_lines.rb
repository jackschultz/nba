class CreateStatLines < ActiveRecord::Migration
  def change
    create_table :stat_lines do |t|
      t.integer :game_id
      t.integer :player_id
      t.integer :team_id
      t.integer :minutes
      t.integer :fgm
      t.integer :fga
      t.float :fg_pct
      t.integer :fg3m
      t.integer :fg3a
      t.float :fg3_pct
      t.integer :ftm
      t.integer :fta
      t.float :ft_pct
      t.integer :oreb
      t.integer :dreb
      t.integer :reb
      t.integer :ast
      t.integer :stl
      t.integer :blk
      t.integer :to
      t.integer :pf
      t.integer :pts
      t.integer :plus_minus

      t.timestamps
    end
  end
end
