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

class UserPlayerCost < ActiveRecord::Base

  belongs_to :user
  belongs_to :player_cost

end
