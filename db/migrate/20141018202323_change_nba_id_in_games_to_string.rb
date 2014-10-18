class ChangeNbaIdInGamesToString < ActiveRecord::Migration
  def change
    change_column :games, :nba_id, :string
  end
end
