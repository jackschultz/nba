# == Schema Information
#
# Table name: teams
#
#  id             :integer          not null, primary key
#  mascot         :string(255)
#  city           :string(255)
#  abbreviation   :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  nba_id         :integer
#  division_id    :integer
#  alternate_name :string(255)
#

class Team < ActiveRecord::Base

  belongs_to :division

  has_many :home_games, :class_name => "Game", :foreign_key => 'home_team_id'
  has_many :away_games, :class_name => "Game", :foreign_key => 'away_team_id'

  has_many :players

  def full_name
    "#{self.city} #{self.mascot}"
  end

end
