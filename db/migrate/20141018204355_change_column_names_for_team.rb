class ChangeColumnNamesForTeam < ActiveRecord::Migration
  def change
    rename_column :teams, :mascot, :nickname
    rename_column :teams, :alternate_name, :alt_nickname
  end
end
