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
  scope :this_season, -> { where('date > ?', Date.new(2014, 10, 27)) }

  def home_team_against_position
    stats = {}
    stats["PG"] = 0
    stats["SG"] = 0
    stats["SF"] = 0
    stats["PF"] = 0
    stats["C"] = 0
    self.stat_lines.where(team_id: home_team_id).each do |sl|
      pc = self.player_costs.primary.find_by_player_id(sl.player_id)
      if !pc.nil?
        stats[pc.position] += sl.score_draft_kings
      end
    end
    return stats
  end

  def away_team_against_position
    stats = {}
    stats["PG"] = 0
    stats["SG"] = 0
    stats["SF"] = 0
    stats["PF"] = 0
    stats["C"] = 0
    self.stat_lines.where(team_id: away_team_id).each do |sl|
      pc = self.player_costs.primary.find_by_player_id(sl.player_id)
      if !pc.nil?
        stats[pc.position] += sl.score_draft_kings
      end
    end
    return stats
  end
end
