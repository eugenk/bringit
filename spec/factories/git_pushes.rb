# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :git_push do
    author nil
    push_type "MyString"
  end
end
