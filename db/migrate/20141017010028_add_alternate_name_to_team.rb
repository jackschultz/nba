class AddAlternateNameToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :alternate_name, :string
  end
end
