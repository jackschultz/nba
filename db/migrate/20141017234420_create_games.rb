class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :nba_id
      t.datetime :date
      t.integer :home_team_id
      t.integer :away_team_id

      t.timestamps
    end
  end
end
