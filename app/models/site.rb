# == Schema Information
#
# Table name: sites
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Site < ActiveRecord::Base

  has_many :player_costs

  def fan_duel?
    self.name == "Fan Duel"
  end

  def draft_kings?
    self.name == "Draft Kings"
  end

end
