# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :repository do
    path "path_to/bringit.git"
    title "bringit"
    description "bringit\nThe simple web-interface for git"
    owners [{email: "user@example.com", 
             password: "password",
             password_confirmation: "password"}]
  end
end
