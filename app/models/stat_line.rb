# == Schema Information
#
# Table name: stat_lines
#
#  id         :integer          not null, primary key
#  game_id    :integer
#  player_id  :integer
#  team_id    :integer
#  minutes    :integer
#  fgm        :integer
#  fga        :integer
#  fg_pct     :float
#  fg3m       :integer
#  fg3a       :integer
#  fg3_pct    :float
#  ftm        :integer
#  fta        :integer
#  ft_pct     :float
#  oreb       :integer
#  dreb       :integer
#  reb        :integer
#  ast        :integer
#  stl        :integer
#  blk        :integer
#  to         :integer
#  pf         :integer
#  pts        :integer
#  plus_minus :integer
#  created_at :datetime
#  updated_at :datetime
#

class StatLine < ActiveRecord::Base

  belongs_to :game
  belongs_to :team
  belongs_to :player

  scope :played, -> { where.not(:pts => nil) }

  def score_fan_duel
    if self.pts.nil?
      0
    else
      (self.pts + (self.reb * 1.2) + (self.ast * 1.5) + (self.blk * 2) + (self.stl * 2) + (self.to * -1)).round(2)
    end
  end

end
