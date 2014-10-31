# == Schema Information
#
# Table name: players
#
#  id               :integer          not null, primary key
#  team_id          :integer
#  first_name       :string(255)
#  last_name        :string(255)
#  underscored_name :string(255)
#  nba_id           :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Player < ActiveRecord::Base

  belongs_to :team

  has_many :player_costs
  has_many :stat_lines


  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def on_team?(team)
    self.team.id == team.id
  end

  def fan_duel_std_dev
    scores = self.stat_lines.played.map(&:score_fan_duel)
    DfsStats::Basic.standard_deviation(scores)
  end

  def avg_draft_kings
    scores = self.stat_lines.played.map(&:score_draft_kings)
    scores.sum.to_f / scores.length
  end

  def avg_minutes
    minutes = self.stat_line.map(&:minutes)
    minutes.inject(:+).to_f / minutes.length
  end

  def avg_fan_duel_points
    self.stat_lines.played
  end

  def fan_duel_points_per_minute
    self.avg_fan_duel_points / self.avg_minutes
  end

  def minutes
    data = Hash.new(0)
    #default hash?
    (0..40).each do |num|
      data[num] = []
    end
    StatLine.played.each do |stat|
      data[stat.minutes] << stat.score_fan_duel
    end
    ret = []
    (0..40).each do |num|
      if data[num].length == 0
        ret << 0
      else
        ret << data[num].inject{ |sum, el| sum + el }.to_f / data[num].length
      end
    end
    ret
  end

end
