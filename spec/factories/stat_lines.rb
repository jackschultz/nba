# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stat_line do
    game_id 1
    player_id 1
    team_id 1
    minutes 1
    fgm 1
    fga 1
    fg_pct 1.5
    fg3m 1
    fg3a 1
    fg3_pct 1.5
    ftm 1
    fta 1
    ft_pct ""
    oreb 1
    dreb 1
    reb 1
    ast 1
    stl 1
    blk 1
    to 1
    pf 1
    pts 1
    plus_minus 1
  end
end
