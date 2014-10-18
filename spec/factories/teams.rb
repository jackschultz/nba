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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team do
    mascot "MyString"
    city "MyString"
    abbreviation "MyString"
  end
end
