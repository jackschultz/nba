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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :game do
    nba_id 1
    date "2014-10-17 18:44:20"
    home_team_id ""
    away_team_id 1
  end
end
