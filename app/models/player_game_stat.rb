# == Schema Information
#
# Table name: player_game_stats
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  game_id    :integer
#  minutes    :integer
#  fga        :integer
#  fgm        :integer
#  fg_pct     :float
#  fg3m       :integer
#  fg3a       :integer
#  fg3_pct    :float
#  ftm        :integer
#  ft_pct     :integer
#  oreb       :integer
#  dreb       :integer
#  rebounds   :integer
#  assists    :integer
#  turnovers  :integer
#  steals     :integer
#  blocks     :integer
#  fouls      :integer
#  points     :integer
#  plus_minus :integer
#  created_at :datetime
#  updated_at :datetime
#  fta        :integer
#

class PlayerGameStat < ActiveRecord::Base

  belongs_to :player
  belongs_to :game

  def score_fan_duel
    (self.fgm * 2) + (self.fg3m * 3) + (self.ftm * 1) + (self.rebounds * 1.2) + (self.assists * 1.5) + (self.blocks * 2) + (self.steals * 2) + (self.turnovers * -1)
  end

end
