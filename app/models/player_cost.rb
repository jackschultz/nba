# == Schema Information
#
# Table name: player_costs
#
#  id           :integer          not null, primary key
#  player_id    :integer
#  game_id      :integer
#  site_id      :integer
#  position     :string(255)
#  alt_position :string(255)
#  salary       :integer
#  created_at   :datetime
#  updated_at   :datetime
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

end
