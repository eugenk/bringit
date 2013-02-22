# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :push do
    push_type 'web'
    repository { FactoryGirl.next(:repository) }
    author { FactoryGirl.next(:user) }
  end
end
