# == Schema Information
#
# Table name: site_player_infos
#
#  id              :integer          not null, primary key
#  site_id         :integer
#  player_id       :integer
#  alt_player_name :string(255)
#  salary          :integer
#  position        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

RSpec.describe SitePlayerInfo, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
