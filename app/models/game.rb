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

  has_one :home_team, class_name: "Team"
  has_one :away_team, class_name: "Team"

end
