# == Schema Information
#
# Table name: site_player_infos
#
#  id              :integer          not null, primary key
#  site_id         :integer
#  player_id       :integer
#  alt_player_name :string(255)
#  salary          :integer
#  position        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class SitePlayerInfo < ActiveRecord::Base

  belongs_to :site
  belongs_to :player

  scope :point_guards , -> { where(:position => "pg") }
  scope :shooting_guards , -> { where(:position => "sg") }
  scope :small_forwards, -> { where(:position => "sf") }
  scope :power_forwards, -> { where(:position => "pf") }
  scope :centers, -> { where(:position => "c") }
  scope :guards , -> { where("position = ? or position = ?", "pg", "sg") }
  scope :forwards, -> { where("position = ? or position = ?", "pf", "sf") }

end
