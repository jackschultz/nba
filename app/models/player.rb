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

  def asdf
    stat_lines = self.stat_lines.played.to_ary
    if stat_lines.length < 2
      return 0,0
    end
    first = stat_lines.delete_at(0)
    second = stat_lines.delete_at(0)
    prev = second
    up = (first.score_fan_duel - second.score_fan_duel) < 0
    trend = 0
    no_trend = 0
    stat_lines.each do |sl|
      if up
        if prev.score_fan_duel > sl.score_fan_duel
          trend += 1
          up = true
        else
          no_trend += 1
          up = false
        end
      else
        if prev.score_fan_duel < sl.score_fan_duel
          trend += 1
          up = true
        else
          no_trend += 1
          up = false
        end
      end
      prev = sl
    end
    return trend, no_trend
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
