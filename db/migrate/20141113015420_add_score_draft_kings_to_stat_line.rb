class AddScoreDraftKingsToStatLine < ActiveRecord::Migration
  def change
    add_column :stat_lines, :score_draft_kings, :float
  end
end
