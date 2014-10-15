class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :mascot
      t.string :city
      t.string :abbreviation

      t.timestamps
    end
  end
end
