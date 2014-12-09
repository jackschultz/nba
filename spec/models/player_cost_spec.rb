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

require 'rails_helper'

RSpec.describe PlayerCost, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
