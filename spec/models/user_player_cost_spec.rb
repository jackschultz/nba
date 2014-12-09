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

require 'rails_helper'

RSpec.describe UserPlayerCost, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
