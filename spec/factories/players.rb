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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :player do
    team nil
    first_name "MyString"
    last_name "MyString"
    underscored_name "MyString"
    nba_id 1
  end
end
