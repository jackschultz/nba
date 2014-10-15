class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.references :team, index: true
      t.string :first_name
      t.string :last_name
      t.string :underscored_name
      t.integer :nba_id

      t.timestamps
    end
  end
end
