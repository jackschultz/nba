# == Schema Information
#
# Table name: players
#
#  id               :integer          not null, primary key
#  team_id          :integer
#  first_name       :string(255)
#  last_name        :string(255)
#  underscored_name :string(255)
#  nba_id           :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Player < ActiveRecord::Base

  belongs_to :team

end
