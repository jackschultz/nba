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

require 'rails_helper'

RSpec.describe Game, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
