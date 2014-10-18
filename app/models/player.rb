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

end
