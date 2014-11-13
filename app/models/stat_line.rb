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

class StatLine < ActiveRecord::Base

  belongs_to :game
  belongs_to :team
  belongs_to :player

  default_scope { joins(:game).order('games.date DESC') }

  scope :from_games, lambda{ |game_ids| where(game_id: game_ids) }
  scope :played, -> { where.not(:minutes => nil) }
  scope :before_date, -> (date) { joins(:game).where('games.date < ?', date) }
  scope :after_date, -> (date) { joins(:game).where('games.date > ?', date) }

  def score_fan_duel
    if self.pts.nil?
      0
    else
      (self.pts + (self.reb * 1.2) + (self.ast * 1.5) + (self.blk * 2) + (self.stl * 2) + (self.to * -1)).round(2)
    end
  end

  def score_draft_kings
    if self[:score_draft_kings].nil?
      if self.pts.nil?
        self[:score_draft_kings] = 0
      else
        self[:score_draft_kings] = (self.pts + (self.fg3m * 0.5) + (self.reb * 1.25) + (self.ast * 1.5) + (self.blk * 2) + (self.stl * 2) + (self.to * -0.5) + (double_double * 1.5) + (triple_double * 1.5)).round(2)
      end
      self.save
    end
    self[:score_draft_kings]
  end

  def double_double
    (double_points + double_rebounds + double_assists + double_blocks + double_steals) >= 2 ? 1 : 0
  end

  def triple_double
    (double_points + double_rebounds + double_assists + double_blocks + double_steals) >= 3 ? 1 : 0
  end

  def double_points
    self.pts >= 10 ? 1 : 0
  end

  def double_rebounds
    self.reb >= 10 ? 1 : 0
  end

  def double_assists
    self.ast >= 10 ? 1 : 0
  end

  def double_blocks
    self.blk >= 10 ? 1 : 0
  end

  def double_steals
    self.stl >= 10 ? 1 : 0
  end

end
