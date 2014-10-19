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

FactoryGirl.define do
  factory :site_player_info do
    site_id 1
player_id 1
alt_player_name "MyString"
salary 1
position "MyString"
  end

end
