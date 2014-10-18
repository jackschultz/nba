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

end
