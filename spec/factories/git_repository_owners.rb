# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :git_repository_owner do
    git_repository nil
    owner nil
  end
end
