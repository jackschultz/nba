class AddGameIdAndAltPositionToSitePlayerInfo < ActiveRecord::Migration
  def change
    add_column :site_player_infos, :alt_position, :string
  end
end
