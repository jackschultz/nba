# == Schema Information
#
# Table name: player_costs
#
#  id               :integer          not null, primary key
#  player_id        :integer
#  game_id          :integer
#  site_id          :integer
#  position         :string(255)
#  salary           :integer
#  created_at       :datetime
#  updated_at       :datetime
#  expected_points  :float
#  actual_points_dk :float
#  healthy          :boolean          default(TRUE)
#  starting         :boolean          default(FALSE)
#  user_id          :integer
#

FactoryGirl.define do
  factory :player_cost do
    player_id 1
game_id 1
site_id 1
position "MyString"
alt_position "MyString"
salary 1
  end

end
