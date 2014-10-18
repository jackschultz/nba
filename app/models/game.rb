# == Schema Information
#
# Table name: games
#
#  id           :integer          not null, primary key
#  nba_id       :integer
#  date         :datetime
#  home_team_id :integer
#  away_team_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Game < ActiveRecord::Base

  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"

  has_many :player_game_stats

  def nba_id_string
    #I should really just store this as a string
    str_nba_id = self.nba_id.to_s
    diff = 10 - str_nba_id.length
    (0..diff-1).each do |i|
      str_nba_id.insert(0, '0')
    end
    str_nba_id
  end

end
