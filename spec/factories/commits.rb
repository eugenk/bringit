# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commit do
    hash SecureRandom.hex(20)
    sequence(:message) { |n| "Add commit message #{n}" }
    committer_email "user@example.com"
    committer_name "Hans Meiser"
    committer_time "2013-02-20 17:54:05"
    author_email "user@example.com"
    author_name "Rita Schneider"
    author_time "2013-02-20 17:54:05"
    push { FactoryGirl.next(:push) }
  end
end
