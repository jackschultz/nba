# == Schema Information
#
# Table name: player_costs
#
#  id               :integer          not null, primary key
#  player_id        :integer
#  game_id          :integer
#  site_id          :integer
#  position         :string(255)
#  salary           :integer
#  created_at       :datetime
#  updated_at       :datetime
#  expected_points  :float
#  actual_points_dk :float
#  healthy          :boolean          default(TRUE)
#

class PlayerCost < ActiveRecord::Base

  belongs_to :site
  belongs_to :player
  belongs_to :game

  scope :point_guards , -> { where(:position => "pg") }
  scope :shooting_guards , -> { where(:position => "sg") }
  scope :small_forwards, -> { where(:position => "sf") }
  scope :power_forwards, -> { where(:position => "pf") }
  scope :centers, -> { where(:position => "c") }
  scope :guards , -> { where("position = ? or position = ?", "pg", "sg") }
  scope :forwards, -> { where("position = ? or position = ?", "pf", "sf") }

  scope :from_games, lambda{ |game_ids| where(game_id: game_ids) }

  attr_accessor :weight_slope

  def set_expected_points!(date = Date.today, lookback = nil)
    beginning_of_season = Date.new(2014, 10, 27)
    stat_lines = self.player.stat_lines.after_date(beginning_of_season).before_date(date).take(lookback)
    if stat_lines.length == 0
      self[:expected_points] = 0
    elsif stat_lines.length == 1
      self[:expected_points] = stat_lines.first.score_draft_kings
    elsif stat_lines.length == 2
      self[:expected_points] = (stat_lines.first.score_draft_kings + stat_lines.first.score_draft_kings)/2.0
    else
      self[:expected_points] = stat_lines[(stat_lines.length/2.0).round].score_draft_kings
    end
    self.save
  end

  def actual_points_dk
    if self[:actual_points_dk].nil?
      stat_line = StatLine.find_by_game_id_and_player_id(self.game.id, self.player.id)
      if stat_line
        self[:actual_points_dk] = stat_line.score_draft_kings
        self.save
      else
        return 0
      end
    end
    self[:actual_points_dk]
  end

  def points
    self[:actual_points_dk] || self.expected_points
  end

  def sg?
    self.position == "SG"
  end

  def pg?
    self.position == "PG"
  end

  def g?
    self.position == "G"
  end

  def sf?
    self.position == "SF"
  end

  def pf?
    self.position == "PF"
  end

  def f?
    self.position == "F"
  end

  def c?
    self.position == "C"
  end

  def u?
    self.position == "U"
  end

  def expected_points_per_dollar
    self.expected_points / self.salary
  end

  def to_json
    data = {}
    data[:position] = self.position
    data[:salary] = self.salary
    data[:expected_points] = self.expected_points
    data[:healthy] = self.healthy
    data[:player] = self.player.to_json
    data
  end

end
