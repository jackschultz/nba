class AddFtaToPlayerGameStats < ActiveRecord::Migration
  def change
    add_column :player_game_stats, :fta, :integer
  end
end
