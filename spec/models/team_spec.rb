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

require 'rails_helper'

RSpec.describe Team, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
