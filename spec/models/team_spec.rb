# == Schema Information
#
# Table name: teams
#
#  id           :integer          not null, primary key
#  nickname     :string(255)
#  city         :string(255)
#  abbreviation :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  nba_id       :integer
#  division_id  :integer
#  alt_nickname :string(255)
#

require 'rails_helper'

RSpec.describe Team, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
