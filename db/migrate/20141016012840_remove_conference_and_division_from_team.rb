class RemoveConferenceAndDivisionFromTeam < ActiveRecord::Migration
  def change
    remove_column :teams, :division
    remove_column :teams, :conference
  end
end
