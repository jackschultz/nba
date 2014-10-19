class CreateSitePlayerInfos < ActiveRecord::Migration
  def change
    create_table :site_player_infos do |t|
      t.integer :site_id
      t.integer :player_id
      t.string :alt_player_name
      t.integer :salary
      t.string :position

      t.timestamps
    end
  end
end
