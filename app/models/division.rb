# == Schema Information
#
# Table name: divisions
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#

class Division < ActiveRecord::Base

  belongs_to :conference

  has_many :teams

end
