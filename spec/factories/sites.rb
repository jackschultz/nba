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

FactoryGirl.define do
  factory :site do
    name "MyString"
url "MyString"
  end

end
