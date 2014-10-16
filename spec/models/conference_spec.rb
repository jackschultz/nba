# == Schema Information
#
# Table name: conferences
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Conference, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
