# == Schema Information
#
# Table name: user_player_costs
#
#  id              :integer          not null, primary key
#  player_cost_id  :integer
#  user_id         :integer
#  expected_points :float
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :user_player_cost do
    player_cost_id 1
user_id 1
expected_points 1.5
  end

end
