# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :repository_owner do
    repository 
    owner
  end
end
