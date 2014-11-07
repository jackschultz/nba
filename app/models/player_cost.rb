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
    self.actual_points_dk || self.expected_points
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

end
