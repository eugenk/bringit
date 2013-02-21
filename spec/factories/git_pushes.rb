# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :push do
    author nil
    push_type "MyString"
  end
end
