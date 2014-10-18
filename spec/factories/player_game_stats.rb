# == Schema Information
#
# Table name: player_game_stats
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  game_id    :integer
#  minutes    :integer
#  fga        :integer
#  fgm        :integer
#  fg_pct     :float
#  fg3m       :integer
#  fg3a       :integer
#  fg3_pct    :float
#  ftm        :integer
#  ft_pct     :integer
#  oreb       :integer
#  dreb       :integer
#  rebounds   :integer
#  assists    :integer
#  turnovers  :integer
#  steals     :integer
#  blocks     :integer
#  fouls      :integer
#  points     :integer
#  plus_minus :integer
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :player_game_stat do
    player_id 1
    game_id 1
    minutes 1
    fga 1
    fgm 1
    fg_pct 1.5
    fg3m 1
    fg3a 1
    fg3_pct ""
    ftm 1
    fga 1
    ft_pct 1
    oreb 1
    dreb 1
    rebounds 1
    assists 1
    turnovers 1
    steals ""
    blocks 1
    fouls 1
    points 1
    plus_minus 1
  end
end
