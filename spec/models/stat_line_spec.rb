# == Schema Information
#
# Table name: stat_lines
#
#  id                :integer          not null, primary key
#  game_id           :integer
#  player_id         :integer
#  team_id           :integer
#  minutes           :integer
#  fgm               :integer
#  fga               :integer
#  fg_pct            :float
#  fg3m              :integer
#  fg3a              :integer
#  fg3_pct           :float
#  ftm               :integer
#  fta               :integer
#  ft_pct            :float
#  oreb              :integer
#  dreb              :integer
#  reb               :integer
#  ast               :integer
#  stl               :integer
#  blk               :integer
#  to                :integer
#  pf                :integer
#  pts               :integer
#  plus_minus        :integer
#  created_at        :datetime
#  updated_at        :datetime
#  score_draft_kings :float
#

require 'rails_helper'

RSpec.describe StatLine, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
