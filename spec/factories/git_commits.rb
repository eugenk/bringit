# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commit do
    hash "MyString"
    message "MyText"
    committer_email "MyString"
    committer_name "MyString"
    committer_time "2013-02-20 17:54:05"
    author_email "MyString"
    author_name "MyString"
    author_time "2013-02-20 17:54:05"
    push_id 1
  end
end
