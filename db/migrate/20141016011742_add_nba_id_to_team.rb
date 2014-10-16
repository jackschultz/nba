class AddNbaIdToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :nba_id, :integer
  end
end
