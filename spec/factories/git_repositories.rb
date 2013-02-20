# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :git_repository do
    path "MyString"
    title "MyString"
    description "MyText"
  end
end
