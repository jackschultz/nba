# == Schema Information
#
# Table name: games
#
#  id           :integer          not null, primary key
#  nba_id       :string(255)
#  date         :datetime
#  home_team_id :integer
#  away_team_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Game < ActiveRecord::Base

  default_scope { order('date DESC') }

  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"

  has_many :player_costs
  has_many :stat_lines

  scope :today, -> {where(date: Date.today.strftime('%F'))}
  scope :on_date, lambda{ |date| where("date = ?", date) }

end
