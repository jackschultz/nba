# == Schema Information
#
# Table name: teams
#
#  id           :integer          not null, primary key
#  mascot       :string(255)
#  city         :string(255)
#  abbreviation :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Team < ActiveRecord::Base
end
