# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :push do
    author User.new(email: "user@example.com", 
                    password: "password", password_confirmation: "password")
    repository Repository.new(path: 'some/path/bringit.git', title: 'bringit!',
                              owners: [User.new(email: "user@example.com", 
                                                password: "password", 
                                                password_confirmation: "password")])
    push_type "web"
  end
end
