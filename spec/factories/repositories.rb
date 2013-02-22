# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :repository do
    path "MyString"
    title "MyString"
    description "MyText"
  end
end
